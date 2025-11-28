# Distance to a Location

MoveApps

Github repository: *github.com/movestore/Distance-To-Loc*

## Description
Calculates the distance to a reference location and plots it for selected individuals.

## Documentation
This app calculates the Vincenty ellipsoidal distance in metres (using the R package geosphere) from all positions to a user-defined reference location.
These distances are then plotted over time as lines in a single plot (one line per individual). The reference location can be changed interactively.
Users can download the plot as a PNG file and save the distance table as a CSV file using the download buttons.

### Application scope
#### Generality of App usability
This App was developed for any taxonomic group. 

#### Required data properties
The App should work for any kind of (location) data.

### Input type
`move2::move2_loc`

### Output type
`move2::move2_loc`

### Artefacts
`distance_plot_lon_lat.png`:PNG file containing the distance–time plot for the selected individuals.

`distance_table_lon_lat.csv`: CSV file containing the distances of the selected individuals to the specified location (incl: track ID, timestamp, longitude, latitude, and distance_to_location).


### Settings 
**Tracks**:
`animals`: select the tracks to include.
`select_all_animals`: button to select all tracks.
`unselect_animals` : button to unselect all tracks.

**Reference Location**:
`Longitude`: longitude of the reference location to which the distance for each data position is calculated. Coordinate has to be in EPSG:4326.
`Latitude`: latitude of the reference location to which the distance for each data position is calculated. Coordinate has to be in EPSG:4326.

**Buttons**:
`Apply Changes`: click on this button to update the calculation after changing the tracks selection or coordinates of the reference position.
`Download plot` : click on this button to download the png-file containing the plot for selected individuals.
`Save Table(csv)` : click on this button to save the csv-file with table of selected individuals' distances to the specified reference location.

### Changes in output data
The input data remains unchanged.

### Most common errors

### Null or error handling

**Setting `Longitude of Reference Location`:** This parameter defaults to 0, which is the Prime Meridian. It can be interactively changed in the UI. It has to be a valid longitude in EPSG:4326

**Setting `Latitude of Reference Location`:** This parameter defaults to 0, which is the Equator. It can be interactively changed in the UI. It has to be a valid latitude in EPSG:4326
