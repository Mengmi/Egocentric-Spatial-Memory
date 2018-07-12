run the following matlab scripts to pre-process the collected maps from ROS:
- mapConversion_IROS_step1.m: convert current local map to pre-defined egocentric coordinate
- mapConversion_IROS_step2.m: generate accumulative free space local map based on all past 31 frames
- mapConversion_IROS_step3.m: generate free space binary maps based on current camera frames
- mapConversion_IROS_step4.m: generate accumulative global map from t = 1 to the last frame
- GenerateTFpose_IROS.m: convert pose to transformation matrix for Spatial Transformer Network in training
- RelativePoseTrainTest_IROS: generate relative pose from time t-1 to t for training and testing
