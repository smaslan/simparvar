# TWM-aux
Simple set of functions for automatic variation of simulation parameters for means of calculating multidimensional sensitivity analysis and uncertainty calculations. It will work for any number of variable parameters. Main purpose was to generate all possible combinations of all parameter in advance, so the particular calculation can be processed using some of the multicore methods, such as 'parfor', 'parcellfun', 'multicore', etc.
Advantage over manual variation using nested for-cycles, this approach is more flexible because change parameter-axes of simulation is just matter of setting desired parameter to a vector. 

## Example

```matlab
  % simulation parameter combinations:
  par.f0 = 1000; % constant
  par.fs = [10000 20000]; % variable
  par.A0 = [1 2 3]; % variable

  % generate parameter combinations:
  [vr, pp] = var_init(par);
  cc = var_get_all_fast(ppp, vr, ...)

  >> cc{1}.f0  = 1000
  >> cc{1}.fs  = 10000
  >> cc{1}.A0  = 1
  
  >> cc{2}.f0  = 1000
  >> cc{2}.fs  = 20000
  >> cc{2}.A0  = 1

  >> cc{3}.f0  = 1000
  >> cc{3}.fs  = 10000
  >> cc{3}.A0  = 2

  >> cc{4}.f0  = 1000
  >> cc{4}.fs  = 20000
  >> cc{4}.A0  = 2
  
  >> cc{5}.f0  = 1000
  >> cc{5}.fs  = 10000
  >> cc{5}.A0  = 3

  >> cc{6}.f0  = 1000
  >> cc{6}.fs  = 20000
  >> cc{6}.A0  = 3

  % perform calculation on each parameters combination: 
  res = cellfun(@my_processing_function, cc);

  % plot dependence of 'res.my_result' on the parameter 'par.A0' for parameter 'par.fs(2)':
  var_plot_results_vect(vr,res,par,{'norm','my_result'},'A0','fs',2);
```  

For working example see demo 'var_example1.m' which performs a simple sensitivity analyses of Windowed RMS calculation algorithm.


## License
The TWM is distributed under [MIT license](./LICENSE.txt).