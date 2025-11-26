# Distance to a Location

MoveApps

Github repository: *github.com/movestore/Distance-To-Loc*


## Description
Calculates the distance to a reference location and plots it for selected individuals.

## Documentation
After downsampling your data, this app calculates the Vincenty ellipsoidal distance in metres (using the R package geosphere) from all positions to a user-defined reference location.
These distances are then plotted over time as lines in a single plot (one line per individual). The reference location can be changed interactively.
Users can download the plot as a PNG file and save the distance table as a CSV file using the download buttons.

### Input data
moveStack in Movebank format

### Output data
Shiny user interface (UI)

### Artefacts
`distance_plot_lon_lat.png`:PNG file containing the distance–time plot for the selected individuals.

`distance_table_lon_lat.csv`: CSV file containing the distances of the selected individuals to the specified location (incl: individual ID, timestamp, longitude, latitude, and distance_to_location).


### Settings 

**Tracks**:
`animals`: checkbox group for selecting the Tracks to include.
`select_all_animals`: Button to select all Tracks.
`unselect_animals` : Button to unselect all Tracks.

**Reference Location**:
`Longitude`: longitude of the reference location to which the distance for each data position is calculated.
`Latitude of Reference Location`: latitude of the position to which the distance for each data position is calculated.

**Buttons**:
`Apply Changes`: click on this button to update the calculation after changing the Tracks or coordinates of the reference position.
`Download plot` : click on this button to download the png-file containing the plot for selected individuals.
`Save Table(csv)` : click on this button to save the csv-file with Table of selected individuals' distances to the specified reference location.


### Null or error handling:
**Track Selection:**  If no tracks are selected when `Apply Changes` is pressed, no plot or output files are generated. Internally, the app requires at least one selected individual before distance calculation and plotting proceed.

**Empty or Invalid Data** If the filtered data set contains no rows, the plot and download handlers are not updated. Coordinates are transformed to WGS84 (EPSG:4326) if needed; records with missing coordinates or timestamps are effectively ignored in the distance calculation.

**Setting `Longitude of Reference Location`:** This parameter defaults to 0, which is the Prime Meridian. It can be interactively changed in the UI.

**Setting `Latitude of Reference Location`:** This parameter defaults to 0, which is the Equator. It can be interactively changed in the UI.

**Data:** The app explores the data interactively. The original input data set is returned unchanged to subsequent workflow steps.

