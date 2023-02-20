import os
import sys
import random
import time

#print message to indicate that the script is running and start timer and dispaly the time
print('Running script...')
start_time = time.time()
print('Start time: ' + time.strftime('%H:%M:%S', time.localtime(start_time)))

# Import QGIS libraries
from qgis.core import QgsApplication, QgsProcessingFeedback, QgsVectorLayer, QgsVectorFileWriter, QgsCoordinateReferenceSystem
from qgis.analysis import QgsNativeAlgorithms

# Import more QGIS libraries and initialize QGIS
QgsApplication.setPrefixPath(r'C:\OSGeo4W\apps\qgis\python', True)
qgs = QgsApplication([], False)
qgs.initQgis()

# Add the path to processing so we can import it next
sys.path.append(r'C:\OSGeo4W\apps\qgis\python\plugins')


# Import processing. 
"""Imports usually should be at the top of a script but this unconventional order is necessary here because QGIS has to be initialized first. If you try to import processing before initializing QGIS you will get an error. Some linters will complain about this but you can ignore the error."""
import processing
from processing.core.Processing import Processing
Processing.initialize()
QgsApplication.processingRegistry().addProvider(QgsNativeAlgorithms())
feedback = QgsProcessingFeedback()

# Set working directory and show message to user to indicate the working directory
wd = r'C:\Users\sbzlm3\OneDrive - The University of Nottingham\Documents\ML-World-Bank-Soils\MalawiVariogram'
print('Working directory: ' + wd)


# Set output file and print message to user to indicate the output file
output_file = wd + r'\data\mwi_sample_points_LM.shp'
print('Output file: ' + output_file)

# Check if the output file exists and delete it if it does then print message to user to indicate the output file has been deleted
if os.path.exists(output_file):
    os.remove(output_file)  # Delete the file
    print('Previous output file deleted')

# Set input polygon file and print message to user to indicate the input polygon file
polygon_file = wd + r'\data\ECHO2_prioritization.shp'

# Check if the polygon file exists if not exit the script with an error message
if not os.path.exists(polygon_file):
    print('The input polygon file does not exist')
    sys.exit()

# Set waterbodies or other area to mask file and print message to user to indicate the waterbodies file
waterbodies_file = wd + r'\data\lake_malawi.shp'
print('Waterbodies file: ' + waterbodies_file)

# Check if the waterbodies file exists if not exit the script with an error message
if not os.path.exists(waterbodies_file):
    print('The input waterbodies file does not exist')
    sys.exit()

# Set number of points to generate and print message to user to indicate the number of points to generate
N = 10000000
print('Number of points to generate: ' + str(N))

# Load the polygon layer and print message to user to indicate the polygon layer has been loaded
polygon_layer = QgsVectorLayer(polygon_file, "polygon", "ogr")
print('Polygon layer loaded')

# Load the waterbodies layer and print message to user to indicate the waterbodies layer has been loaded
waterbodies_layer = QgsVectorLayer(waterbodies_file, "waterbodies", "ogr")
print('Waterbodies layer loaded')

# Dissolve the administrative regions to get the outer boundary and print message to user to indicate the boundary has been dissolved
bound_layer = processing.run("native:dissolve", {'INPUT': polygon_layer,
                                                 'FIELD': [],
                                                 'SEPARATE_DISJOINT': False,
                                                 'OUTPUT': 'memory:'})['OUTPUT']
print('Boundary dissolved')

# Mask the waterbodies from the dissolved polygon and print message to user to indicate the waterbodies have been masked
diff_params = {
    'INPUT': bound_layer,
    'OVERLAY': waterbodies_layer,
    'OUTPUT': 'TEMPORARY_OUTPUT',
    'GRID_SIZE': None
}

masked_bound_layer = processing.run(
    "native:difference", diff_params)['OUTPUT']
print('Waterbodies masked')

# Generate random points within the bounds of the administrative regions masking waterbodies and print message to user to indicate the random points have been generated
random.seed(123)
random_points_layer = processing.run("qgis:randompointsinsidepolygons", {
    'INPUT': masked_bound_layer,
    'STRATEGY': 0,
    'VALUE': N,
    'MIN_DISTANCE': None,
    'OUTPUT': 'memory:'})['OUTPUT']
print('Random points generated')

# Join the polygon attributes with the random points and print message to user to indicate the attributes have been joined
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
print('Attributes joined')

# Add the geometry attributes table and print message to user to indicate the geometry attributes table has been added
result_layer_wa = processing.run("qgis:exportaddgeometrycolumns", {
    'INPUT': result_layer,
    'CALC_METHOD': 0,
    'OUTPUT': 'TEMPORARY_OUTPUT'})['OUTPUT']
print('Geometry attributes added')


# Save the result layer as a shapefile and print message to user to indicate the shapefile has been saved and the location of the shapefile
QgsVectorFileWriter.writeAsVectorFormat(
    result_layer_wa, output_file, "UTF-8", result_layer.crs(), "ESRI Shapefile")
print('Shapefile saved: ' + output_file)

# Print message to user to indicate the script has finished
print('Script finished successfully')

#Print the total time taken to run the script
print('Start time: ' + time.strftime('%H:%M:%S', time.localtime(time.time())))
print('End time: ' + time.strftime('%H:%M:%S', time.localtime(time.time())))
print('Total time: ' + str(time.time() - start_time))

# Load the result layer into QGIS canvas. This is not necessary but it is useful for debugging. It should be commented out when running the script in batch mode.
# iface.addVectorLayer(output_file)
