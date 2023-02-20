# This script creates a random sample of points within the administrative regions of Malawi. It should be run in QGIS with the Python Console open.

# Import modules
import processing
import random


# Set working directory
wd = r'C:\Users\sbzlm3\OneDrive - The University of Nottingham\Documents\MWI-World-Bank-Variograms-ML'

# Set the output file as a shapefile. The output file will be saved in the data/point_outputs folder
output_file = wd + r'\data\point_outputs\mwi_sample_points.shp'


# Check if the output file exists and delete it if it does
if os.path.exists(output_file):
    # check if the output file is loaded in QGIS session and remove it if it is
    # if iface.activeLayer().source() == output_file:
    #     iface.activeLayer().removeAllFeatures()   
    os.remove(output_file)  # Delete the file


# Set input polygon file
polygon_file = wd + r'\data\admin_inputs\mwi_eas_acho\echo2_prioritization\ECHO2_prioritization.shp'

# Check if the polygon file exists if not exit the script with an error message
if not os.path.exists(polygon_file):
    print('The input polygon file does not exist')
    

# Set waterbodies or other area to mask file
waterbodies_file = wd + r'\data\admin_inputs\mwi_eas_acho\lake_malawi.shp'

# Check if the waterbodies file exists if not exit the script with an error message
if not os.path.exists(waterbodies_file):
    print('The input waterbodies file does not exist')
    

# Set number of points to generate
N = 1000

# Load the polygon layer
polygon_layer = QgsVectorLayer(polygon_file, "polygon", "ogr")

# Load the waterbodies layer
waterbodies_layer = QgsVectorLayer(waterbodies_file, "waterbodies", "ogr")

# Dissolve the administrative regions to get the outer boundary
bound_layer = processing.run("native:dissolve", {'INPUT': polygon_layer,
                                                 'FIELD': [],
                                                 'SEPARATE_DISJOINT': False,
                                                 'OUTPUT': 'memory:'})['OUTPUT']


# Mask the waterbodies from the dissolved polygon
diff_params = {
    'INPUT': bound_layer,
    'OVERLAY': waterbodies_layer,
    'OUTPUT': 'TEMPORARY_OUTPUT',
    'GRID_SIZE': None
}

masked_bound_layer = processing.run(
    "native:difference", diff_params)['OUTPUT']

# Generate random points within the bounds of the administrative regions masking waterbodies
# random.seed(123)
random_points_layer = processing.run("qgis:randompointsinsidepolygons", {
    'INPUT': masked_bound_layer,
    'STRATEGY': 0,
    'VALUE': N,
    'MIN_DISTANCE': None,
    'OUTPUT': 'memory:'})['OUTPUT']


# Join the polygon attributes with the random points
join_params = {
    'DISCARD_NONMATCHING': False,
    'FIELD': [],
    'INPUT': random_points_layer,
    'JOIN': polygon_layer,
    'JOIN_FIELDS': [],
    'METHOD': 0,
    'OUTPUT': 'memory:'
}

result_layer = processing.run("native:joinattributesbylocation", {'INPUT': random_points_layer,
                                                                  'PREDICATE': [
                                                                      0],
                                                                  'JOIN': polygon_layer,
                                                                  'JOIN_FIELDS': [],
                                                                  'METHOD': 0,
                                                                  'DISCARD_NONMATCHING': False,
                                                                  'PREFIX': '',
                                                                  'OUTPUT': 'memory:'})['OUTPUT']

# Add the geometry attributes table
result_layer_wa = processing.run("qgis:exportaddgeometrycolumns", {
    'INPUT': result_layer,
    'CALC_METHOD': 0,
    'OUTPUT': 'TEMPORARY_OUTPUT'})['OUTPUT']

#

# Save the result layer
QgsVectorFileWriter.writeAsVectorFormat(
    result_layer_wa, output_file, "UTF-8", result_layer.crs(), "ESRI Shapefile")

# Print script completion message and the output file path
print('Script completed. Output file saved to:' + wd + output_file)


# Load the output layer to QGIS
iface.addVectorLayer(output_file, "mwi_sample_points", "ogr")