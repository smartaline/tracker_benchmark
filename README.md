This part of code is the research content during the student period.
We distribute our library under the GNU-GPL license.
If you use this library or the dataset, please cite our paper:
[1] http://en.cnki.com.cn/Article_en/CJFDTotal-XXWX201712012.htm.

[2] https://doi.org/10.1016/j.ins.2019.02.043.


The information for trackers is listed in the file Trackers.txt.

The notes for the folders:
* All the tracking results used in [1]  [2]are stored in the folders.
* The annotation files (bounding box and attributes) are in the folder '.\anno'.
* The folder '.\initOmit' contains the annotation of frames that are omitted for tracking initialization due to occlusion or out of view of targets.
* The tracking results will be stored in the folder '.\results'.
* The folder '.\rstEval' contains some scripts used to compute the tracking performance or draw the results.
* The folder '.\trackers' contains all the code for trackers
* The folder '.\tmp' is used to store some temporary results or log files.
* The folder '.\util' ontains some scripts used in the main functions.

1.Setup for trackers
	*platform: Windows
	*the 5 vivid trackers and TLD can only run on 32 bit Matlab
	*ASLA depends on vlfeat
	*BSBT, BT, SBT, CPF, Frag, KMS, SMS depend on opencv 1.0
	*MIL depends on IPP 5.0 and opencv 1.0
	*Struck depends on opencv 1.0 and Eigen library
	*LSK depends on MATLAB Compiler Runtime (MCR) 7.16
		location: <matlabroot>\toolbox\compiler\deploy\win32\MCRInstaller.exe
	*CXT depends on opencv 2.4 and the DLLS are included
	*VTD and VTS have GUI so that they cannot be included in our library
2.main functions
	* main_running.m is the main function for the tracking test
		- Note that OPE is the first trial of TRE 
		- It also has the function to validate the results.
	* perfPlot.m is the main function for drawing performance plots.
		- It will call 'genPerfMat.m' to generate the values for plots.
	* drawResultBB.m is the main function for drawing bounding boxes (BBs) of different trackers on each frame	
3.results

（1）跟踪的平均覆盖率
	
  ![跟踪的平均覆盖率](https://github.com/smartaline/tracker_benchmark/blob/main/results/AverageCoverage.png)
	
（2）不同影响因素对应的成功图和精度图
	
  ![不同影响因素对应的成功图和精度图](https://github.com/smartaline/tracker_benchmark/blob/main/results/OPE.png)
	
（3）9个算法跟踪12个视频的结果
	
  ![9个算法跟踪12个视频的结果](https://github.com/smartaline/tracker_benchmark/blob/main/results/tracker_result.png)


## Citation

If you find this project useful for your research, please use the following BibTeX entry.

    @contact{15961708129@163.com,
      title={Objects as Points},
      author={Alin.Wang},
      year={2017}
    }
