import pandas as pd
import numpy as np
import geopandas as gpd
from shapely.geometry import Point, box
import cartopy.crs as ccrs
import cartopy.feature as cfeature

def create_geodf(data, geom_type='polygon', crs=None, lon_col=None, lat_col=None):
    """  
    Parameters:
    - data (DataFrame or list of geometries): The data to convert into a GeoDataFrame.
    - geom_type (str): The type of geometry to create ('polygon' or 'point').
    - crs (str or dict): The Coordinate Reference System for the GeoDataFrame. 4326 is the most common crs. 32617 if meters are matters
    - lon_col (str): The name of the longitude column (required if geom_type is 'point').
    - lat_col (str): The name of the latitude column (required if geom_type is 'point').
    
    Returns:
    - gdf (GeoDataFrame): The resulting GeoDataFrame.
    """
    if geom_type == 'polygon':
        # Expecting a list of polygons or a DataFrame with a 'geometry' column
        gdf = gpd.GeoDataFrame(data, geometry=data['geometry'] if isinstance(data, pd.DataFrame) else data, crs=crs)
    
    elif geom_type == 'point':
        # Expecting a DataFrame with longitude and latitude columns
        if lon_col is None or lat_col is None:
            raise ValueError("Longitude and Latitude column names must be provided for point geometries.")
        gdf = gpd.GeoDataFrame(data, geometry=gpd.points_from_xy(data[lon_col], data[lat_col]), crs=crs)
    
    else:
        raise ValueError("Invalid geom_type. Must be either 'polygon' or 'point'.")
    
    return gdf


def change_crs(data, epsg=4326):
    '''Default epsg=4326 (most common)
    For km calculations epsg=32617'''
    return data.to_crs(epsg)


def create_grid_cells(data, grid_size_in_meters):
    minx, miny, maxx, maxy = data.total_bounds
    minx-=2000
    miny-=2000
    grid_cells=[]
    x=minx
    x_axis_list=[]
    y_axis_list=[]
    x_axis=0
    y_axis=0

    while x <maxx:
        y = miny
        y_axis=0
        while y<maxy:
            cell = box (x, y, x+grid_size_in_meters, y+grid_size_in_meters)
            grid_cells.append(cell)
            y+=grid_size_in_meters
            x_axis_list.append(x_axis)
            y_axis_list.append(y_axis)
            y_axis+=1    
        x+=grid_size_in_meters
        x_axis+=1
    
    return grid_cells,x_axis_list,y_axis_list