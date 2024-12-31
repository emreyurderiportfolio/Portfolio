import pandas as pd
import numpy as np

def drop_missing_latlong(data):
    #Records with no coordinate information will be dropped
    data.drop(data[data["demand_lat"].isnull()==True].index, axis=0, inplace=True)
    data.drop(data[data["demand_lon"].isnull()==True].index, axis=0, inplace=True)
    data=data[(data['demand_lat']!=0)|(data['demand_lon']!=0)]
    return print(f"The rows with missing latitude and longitude values are deleted")

def date_and_time_transformation(data):
    #DateTime/TimeStamp transformations
    data['Demand_received']=pd.to_datetime(data['Demand_received'])
    data['Demand_reached']=pd.to_datetime(data['Demand_reached'])
    data['Demand_completed']=pd.to_datetime(data['Demand_completed'])
    return print("Receive time, reach time and completion time have been converted into datetime and timestamp format")


def calculate_arrive_time(data, time=60):
    #Calculating arrive time based on when the demand was responsed and when the demand was received
    data['Arrive_time']=data['Demand_reached']-data['Demand_received']
    data['Arrive_time']=data['Arrive_time'].dt.seconds/time
    return print(f"Arrive time is calculated by ReachTime - ReceivedTime")

def data_restriction_by_arrive_time(data,sigma=2): #Updated based on the mock data. Original is slightly different
    
    """
    According to the empric rule, in a normal distribution 
    values between (mean +- 1sigma) covers the 67% of the all data, 
    95% and 99.7% for 2 and 3 sigma respectively.
    Number of records above 2sigma (as default) from the median for 'Arrive time'
"""    
    arrive_std=data['Arrive_time'].std()
    arrive_mean=data['Arrive_time'].mean()

    rec_num=len(data[data['Arrive_time']>=(arrive_mean+sigma*arrive_std)].index)
    
    data.drop(data[data['Arrive_time']>=(arrive_mean+sigma*arrive_std)].index, axis=0, inplace=True)
    print(f"{rec_num} records have been eliminated due to exceeding the {sigma}sigma limit")
    return print("Dataset has been restricted according to the given standard deviation boundaries in Arrive Time feature")

#Creating bins for the arrival time
def create_bins(val=0, step=4, max=60):
    first_bin= (val//step)*step
    second_bin=((val//step)+1)*step
    if first_bin>=max:
        return f"{max}+"
    else:
        return f"{first_bin}-{second_bin}"
#Alternative approach
#bins=[0,5,10,15,30,45,60]

#arrived_time_data['arrive_data_bins']=pd.cut(arrived_time_data['Arrive_time'], bins)

def create_time_components(data,feature):
    #For more detailed time and date analysis, Demand_received has been parsed into its' components
    data['Demand_time'] = data[feature].dt.time
    data['Demand_date'] = data[feature].dt.date
    data['Demand_day'] = data[feature].dt.day
    data['Demand_month']=data[feature].dt.month
    data['Demand_year']=data[feature].dt.year
    data['Demand_hour']=data[feature].dt.hour
    data['Demand_dayofweek']=data[feature].dt.weekday
    return print(f"Time, date, day, month, year, hour, dayofweek components are created for {feature}")

def concatenate(string1, string2):
    #Concatenate function for general use
    return str(string1)+'-'+str(string2)

def create_daily_freq(data):
    #Creating new column with daily frequency
    daily_call=data.groupby(by="Demand_date")['demand_id'].count()
    daily_call_map=dict(zip(daily_call.index, daily_call.values))

    data['daily_freq']=data['Demand_date'].map(daily_call_map)
    return print("Daily frequence column has been created")

def priority_data_type(data):
    '''
    Some of the priorities recorded string, while the others are numeric.
    Function converts all of them into integer'''
    data.drop(data[data['Call_type']=='H'].index, axis=0, inplace=True)
    data['Call_type'] = data['Call_type'].apply(lambda x: int(x) if pd.notna(x) else 'nan')
    return print("All priority data types converted into integer and priority with 'H' removed from the dataset")

def removing_duplicated_calls_from_same_location(data):
    #In the original dataset, after the analysis it was found that some demands made from the same location, 
    # but not all other columns were identical. To clean the dataset the following function was created.
    #First cleaning step:
    data.drop_duplicates(inplace=True)
    print("Duplicated rows are removed")
    
    #Second cleaning step:
    #Create a new index to identify the duplicated calls from same location
    data['temp_index'] = data.apply(lambda row: str(row['Demand_received'])+"-"+str(row["demand_lat"])+"-"+str(row['demand_lon']), axis=1)
    #Finding the number of rows with the same T1 datetime from the same location
    df_same_day_calls = pd.DataFrame(data['temp_index'].value_counts()).reset_index()
    df_same_day_calls_map = dict(zip(df_same_day_calls['temp_index'],df_same_day_calls['count']))
    data['same_day_call_freq'] = data['temp_index'].map(df_same_day_calls_map)
    #Finding the minimum T4 datetime to be preserved among the group of data with the same T1 datetime
    min_arrived_scene = data.groupby(by='temp_index').agg({"Demand_reached":"min"}).reset_index()
    min_arrived_scene_map = dict(zip(min_arrived_scene['temp_index'],min_arrived_scene['Demand_reached']))

    data['min_demand_reached'] = data[(data['same_day_call_freq']>1)&
                                                      (data['Call_type']==4)]['temp_index'].map(min_arrived_scene_map)
    
    removed_arrive_time_index=data[(data['min_demand_reached'].isnull()==False) &(data['min_demand_reached']!=data['Demand_reached'])].index
    data.drop(removed_arrive_time_index, axis=0,inplace=True)
    data.reset_index(inplace=True)
    data.drop("index", axis=1, inplace=True)
    
    #Third cleaning step:
    #After the second elimination checking for the remaining duplicated rows.
    df_same_day_calls_v2 = pd.DataFrame(data[data['Call_type']==4]['temp_index'].value_counts()).reset_index()
    df_same_day_calls_map_v2 = dict(zip(df_same_day_calls_v2['temp_index'],df_same_day_calls_v2['count']))
    data['same_day_call_freq'] = data['temp_index'].map(df_same_day_calls_map_v2)
    #Preserving only the records with the highest index value among the remaning duplicated T1 datetime groups.  
    data.reset_index(inplace=True)
    highest_index=data[data['same_day_call_freq']>1].groupby(by='temp_index').agg({"index":"max"}).reset_index()
    highest_index_map=dict(zip(highest_index['temp_index'],highest_index['index']))
    data['highest_index'] = data['temp_index'].map(highest_index_map)
       
    removed_arrive_time_index_v2 = data[(data['same_day_call_freq']>1)&
              (data['index'] != data['highest_index'])].index
    
    data.drop(removed_arrive_time_index_v2,axis=0,inplace=True)
    #Removing the temporary columns that created for the function
    data.drop(['temp_index','same_day_call_freq','min_demand_reached','highest_index'], axis=1, inplace=True)
    
    return print("Records with the same T1_ReceivedCalls from the same locations are singularized")
    
    

def main_processing(data):
    print("Basic preprocessing steps are executed...")
    print("drop_missing_latlong function is executed")
    drop_missing_latlong(data)
    print()
    print("date_and_time_transformation function is executed")
    print()
    date_and_time_transformation(data)
    print()
    print("calculate_arrive_time function function is executed")
    calculate_arrive_time(data)
    print()
    print("data_restriction_by_arrive_time function is executed")
    data_restriction_by_arrive_time(data)
    print()
    print("calculate_arrive_time function is executed")
    calculate_arrive_time(data)
    print()
    data['arrive_data_bins']=data.apply(lambda row: create_bins(row['Arrive_time']),axis=1)
    print("arrival time bins are created")
    print()
    print("create_time_components function is executed for T1")
    create_time_components(data=data, feature="Demand_received")
    print()
    data['Demand_month_year']=data.apply(lambda row: concatenate(row['Demand_month'], row['Demand_year']), axis=1)
    data['T1_month_year']=pd.to_datetime(data['Demand_month_year'], format='%m-%Y')
    print("Month-year concatenation has been created")
    print()
    print("priority_data_type function is executed")
    priority_data_type(data)
    print()
    print("create_daily_freq function is executed")
    create_daily_freq(data)
    print()
    print("removing_duplicated_calls_from_same_location function is executed")
    removing_duplicated_calls_from_same_location(data)
    return print("Basic data preprocessing is completed")
    