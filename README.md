
## How to use Kalibr
1. Prepare Files:
   ```bash
    $ vim april_grid.yaml
    # Content:
    target_type: 'aprilgrid' #gridtype
    tagCols: 6               #number of apriltags
    tagRows: 6               #number of apriltags
    tagSize: 0.088           #size of apriltag, edge to edge [m]
    tagSpacing: 0.3          #ratio of space between tags to tagSize
    ```
    and
    ```bash
    $ vim imu.yaml
    # Content:
    accelerometer_noise_density: 1.86e-03   #Noise density (continuous-time)
    accelerometer_random_walk:   4.33e-04   #Bias random walk
    
    gyroscope_noise_density:     1.87e-04   #Noise density (continuous-time)
    gyroscope_random_walk:       2.66e-05   #Bias random walk
    
    rostopic:                    /cam_base/imu      #the IMU ROS topic
    update_rate:                 100.0      #Hz (for discretization of the values above)
    ```
2. Calibrate camera:
    ```bash
    # parallels @ parallel-ubuntu-20 in ~/.ros/bagfiles/waterloo_steel_demo/session_0 [13:12:18]
    $ rosrun kalibr kalibr_calibrate_cameras --models pinhole-radtan --target april_grid.yaml --bag 5_DEMO_14_recording_2023-02-03-10-10-44.bag --topics /cam_base/color/image_raw
    ```
3. Calibrate camera with imu:
    ```bash
    # parallels @ parallel-ubuntu-20 in ~/.ros/bagfiles/waterloo_steel_demo/session_0 [13:12:18]
    $ rosrun kalibr kalibr_calibrate_imu_camera --imu imu.yaml --target april_grid.yaml --bag 5_DEMO_14_recording_2023-02-03-10-10-44.bag  --cam 5_DEMO_14_recording_2023-02-03-10-10-44-camchain.yaml
    ```


### Useful Related Links:
- https://support.stereolabs.com/hc/en-us/articles/360012749113-How-can-I-use-Kalibr-with-the-ZED-Mini-camera-in-ROS-
- 
