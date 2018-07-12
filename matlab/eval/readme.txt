run the following matlab scripts to post-process the predicted maps from our EMS model and visualize results:
- EvalLocalMapsEvery32Frames.m: evaluate accumualtive local maps every 32 frames using MSE, correlation, and MI (see papers)
- DisplayLocalMapsEvery32Frames.m: visualize the predicted accumulative free space local map based on all past 31 frames

- GenerateGlobalForDisplay.m: post-process global maps for visualization
- GenerateLocalOfGlobalForDisplay.m: post-process local maps for visualization
- DisplayGlobalMap.m: distplay predicted maps and store in .gif or .avi format

- LoopClosePrecisionRecallPlot.m: generate precision-recall curve in the paper
- DisplayLoopClosureDetection_triplet.m: display agent position in local maps where the loop closure is detected
