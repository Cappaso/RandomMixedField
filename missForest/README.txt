
1. NOTICEMENT for 'missForest' wrapper.
1) The wrapper calls R in BATCH mode:
The BATCH mode excutes via writing/reading temp_in/temp_out files.
So one can no longer run multiple MATLAB in parallel, since the multiple MATLABs are acessing and modifying the same two files. This is why the results can be mysterious in parallel computing.

2) An alternative way to parallel:
Use copies of folders with different names. But still a lot of editing work to do.


2. NOTICEMENT for MATLAB version.
1) The code is tested under MATLAB R2014a.

2) Especially about plotting, the 'tightfig.m' works well under R2014a.
However, it doesn't work properly under newer versions, such as, R2014b, etc.

The bug happens in the following command:
=========================================
% get all the axes handles note this will also fetch legends and colorbars as well
hax = findall(hfig, 'type', 'axes');
=========================================
Under R2014b, the above command can only get handles of axes. In addition, the handles are no longer numeric values, but objects instead.