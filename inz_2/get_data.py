import geopandas as gpd

# the number of fires in each state is needed, within a year, and then, the map with this data is needed
gdf = gpd.read_file("WFIGS_Current_Interagency_Fire_Perimeters.geojson")

states_us = gdf["attr_POOState"]

gdf['state'] = states_us.replace(to_replace="US-", value="", regex=True)
gdf['month'] = gdf['attr_FireDiscoveryDateTime'].dt.month

gdf['acres'] = gdf['attr_IncidentSize']

areas = {
    'AK': 131171,
    'AL': 1477953,
    'AZ': 294207,
    'CA': 403466,
    'CO': 268431,
    'HI': 16635,
    'ID': 214045,
    'IL': 143793,
    'LA': 111898,
    'MA': 20202,
    'MI': 146435,
    'MN': 206232,
    'MS': 121531,
    'MT': 376962,
    'NM': 314161,
    'OR': 248608,
    'TX': 676587,
    'UT': 212818,
    'WA': 172119,
}

numbers = {}
for state in states_us:
    if state in numbers:
        numbers[state] += 1
    else:
        numbers[state] = 1

months_sum = []
for i in [6, 7, 8, 9, 10]:
    months = {}
    sorted_months = {}
    for j in gdf['state']:
        state_df = gdf[gdf['state'] == j]
        appearance_sum = (state_df['month'] == i).sum()
        months[j] = appearance_sum
        months = {key: val for key, val in months.items() if val != 0}
        months_keys = list(months.keys())
        months_keys = sorted(months_keys)
        sorted_months = {i: months[i] for i in months_keys}

    for j in sorted_months.values():
        months_sum.append(j)

gdf_fires = gdf.groupby(['state', 'month']).acres.sum().reset_index()
gdf_fires['burnt area [km2]'] = gdf_fires['acres'] * 0.004
gdf_fires['number of fires'] = gdf.groupby(['state', 'month']).acres.count().reset_index()['acres']
gdf_fires['state area [km2]'] = gdf_fires['state'].map(areas, na_action='ignore')
gdf_fires['burnt area [%]'] = (gdf_fires['burnt area [km2]'] / gdf_fires['state area [km2]']) * 100
gdf_fires = gdf_fires.sort_values(by="month")
gdf_fires = gdf_fires.reset_index(drop=True)