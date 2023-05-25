<toc>

# Table of Contents
[*Last generated: Thu 02 Mar 2023 05:40:57 PM EST*]
  - [VINS](#VINS)
    - [Ceres 2.0.0](#Ceres-200)
    - [Perform VINS Demo on Recorded bag files (dependency on jack's private repo):](#Perform-VINS-Demo-on-Recorded-bag-files-dependency-on-jacks-private-repo)
    - [Bag Live Player (Plotter):](#Bag-Live-Player-Plotter)
  - [How to use Kalibr](#How-to-use-Kalibr)
    - [Useful Related Links:](#Useful-Related-Links)

---
</toc>

# VIO
## 1. VINS

- Require Ceres 2.0.0

### 1.1 Ceres 2.0.0
- ubuntu 20 [VINS Fusion support for Ubuntu 20.04 with Ceres Solver 2.0.0 HKUST-Aerial-Robotics/VINS-Fusion#187](https://github.com/HKUST-Aerial-Robotics/VINS-Fusion/pull/187)

- ```bash
  $ cd JX_Linux
  $ wget http://ceres-solver.org/ceres-solver-2.0.0.tar.gz
  $ tar zxf ceres-solver-2.0.0.tar.gz
  $ mkdir ceres-bin
  $ cd ceres-bin
  $ cmake ../ceres-solver-2.0.0
  $ make -j6
  $ make test
  $ sudo make install
  ```
### 1.2 Perform VINS Demo on Recorded bag files (dependency on jack's private repo):
```bash
$ cd_ws
## Base camera:
$ ./waterloo_steel/waterloo_steel_demo/waterloo_steel_analyzer/shortcuts/tmux_vins.sh base
## EE camera:
$ ./waterloo_steel/waterloo_steel_demo/waterloo_steel_analyzer/shortcuts/tmux_vins.sh EE

### options:
$ ./waterloo_steel/waterloo_steel_demo/waterloo_steel_analyzer/shortcuts/tmux_vins.sh EE <bag_file_path>
$ ./waterloo_steel/waterloo_steel_demo/waterloo_steel_analyzer/shortcuts/tmux_vins.sh EE bagfiles/waterloo_steel_demo/session_0/0_DEMO_12_recording_2023-02-03-10-05-10.bag
```
- You may live view the plot with Live Player above

### 1.3 Bag Live Player (Plotter):
```bash
$ roslaunch waterloo_steel_analyzer main.launch 
### option:
$ roslaunch waterloo_steel_analyzer main.launch bag_file:=bagfiles/waterloo_steel_demo/session_0/0_DEMO_12_recording_2023-02-03-10-05-10.bag
```
![Example](docs/figs/plot_2023_02_23_17_19.png)


# 2. Calibration
## 2,1 How to use Kalibr
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
    $ rosrun kalibr kalibr_calibrate_cameras --models pinhole-radtan --target april_grid.yaml --bag 5_DEMO_14_recording_2023-02-03-10-10-44.bag --topics /cam_base/color/image_raw --bag-from-to 0 10
    ```
3. Calibrate camera with imu:
    ```bash
    # parallels @ parallel-ubuntu-20 in ~/.ros/bagfiles/waterloo_steel_demo/session_0 [13:12:18]
    $ rosrun kalibr kalibr_calibrate_imu_camera --imu imu.yaml --target april_grid.yaml --bag 5_DEMO_14_recording_2023-02-03-10-10-44.bag  --cam 5_DEMO_14_recording_2023-02-03-10-10-44-camchain.yaml --bag-from-to 0 10
    ```
### 2.1.0  Kalibr Dependency
```bash
$ sudo apt-get install python3-catkin-tools python3-osrf-pycommon # ubuntu 20.04
$ sudo apt-get install -y \
    git wget autoconf automake nano \
    libeigen3-dev libboost-all-dev libsuitesparse-dev \
    doxygen libopencv-dev \
    libpoco-dev libtbb-dev libblas-dev liblapack-dev libv4l-dev
# Ubuntu 20.04
$ sudo apt-get install -y python3-dev python3-pip python3-scipy \
    python3-matplotlib ipython3 python3-wxgtk4.0 python3-tk python3-igraph python3-pyx
```
## 2.2 How to calibrate IMU (Allan Variance):

- L515 imu: [Bosch BMI085 : https://www.mouser.com/datasheet/2/783/BST-BMI085-DS001-13-1365812.pdf]


### 2.1.a Useful Related Links:
- https://support.stereolabs.com/hc/en-us/articles/360012749113-How-can-I-use-Kalibr-with-the-ZED-Mini-camera-in-ROS-

- see unit https://github.com/ethz-asl/kalibr/wiki/IMU-Noise-Model
   - https://github.com/ethz-asl/kalibr/issues/354#issuecomment-979934812
   - Still IMU Calibration:
     - https://github.com/ori-drs/allan_variance_ros <-- still maintained
       - Place your IMU on some damped surface and record your IMU data to a rosbag. You must record **at least** 3 hours of data. 
     - https://github.com/gaowenliang/imu_utils 
     - https://github.com/rpng/kalibr_allan
     - https://github.com/AlbertoJaenal/imu_still_calibration

1. cook the bag:
    ```bash
    $ rosrun allan_variance_ros cookbag.py --input imu_2023-02-27-12-20-36.bag --output data/cook_imu_2023-02-27-12-20-36.bag
    ```
2. allan variance compute

    ```bash
    $ vim config/l515.yaml
    # create `config/l515.yaml` with:
    imu_topic: "/cam_base/imu"
    imu_rate: 400
    measure_rate: 100 # Rate to which imu data is subsampled
    sequence_time: 10800 # 3 hours in seconds

    # compute:
    $ rosrun allan_variance_ros allan_variance data config/l515.yaml
    ```
3. Analysis:
    ```bash
    $ rosrun allan_variance_ros analysis.py --data data/allan_variance.csv
    ```

   ```bash
   accelerometer_noise_density: 0.0011772     # [(m/s^2))(1/sqrt(Hz))] = 120 x e-6 x 9.81 m/s^2/sqrt(Hz)
   accelerometer_random_walk:   0.001            # [(m/s^3))(1/sqrt(Hz))] from {Allan standard deviation (AD)}
   
   gyroscope_noise_density:     0.0002443461  # [(rad/s))(1/sqrt(Hz))] = 0.014^deg/s/sqrt(Hz)
   gyroscope_random_walk:       0.0002     # [(rad/s^2))(1/sqrt(Hz))] from {Allan standard deviation (AD)}
   
   rostopic:                    /cam_base/imu # the IMU ROS topic
   update_rate:                 100.0         # [Hz] (for discretization of the values above)
   ```

   - calibrate from https://github.com/ori-drs/allan_variance_ros [2023/02/28]

   - ```bash
     $ cat ../../imu_static/imu.yaml 
     #Accelerometer
     accelerometer_noise_density: 0.0019979963400731035 
     accelerometer_random_walk: 0.0001510591826346053 
     
     #Gyroscope
     gyroscope_noise_density: 0.00015066033240221485 
     gyroscope_random_walk: 7.126058907243516e-06 
     
     rostopic: /cam_base/imu #Make sure this is correct
     update_rate: 100.0 #Make sure this is correct
     ```

```bash
/home/jx/UWARL_catkin_ws/src/waterloo_steel/waterloo_steel_demo/waterloo_steel_analyzer/shortcuts/batch_tmux_vins.sh waterloo_steel_demo_0519 mono_rgb_imu EE d455 all all accurate_T_ic -1 -1 && /home/jx/UWARL_catkin_ws/src/waterloo_steel/waterloo_steel_demo/waterloo_steel_analyzer/shortcuts/batch_tmux_vins.sh waterloo_steel_demo_0519 mono_rgb_imu base d455 all all accurate_T_ic -1 -1 
```



<eof>

---
[*> Back To Top <*](#Table-of-Contents)
</eof>