# rotate the mesh by 90degrees
# then pull in the z direction - should be no plasticity
[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmin = -0.5
  xmax = 0.5
  ymin = -0.5
  ymax = 0.5
  zmin = -0.5
  zmax = 0.5
[]


[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
[]

[Kernels]
  [./TensorMechanics]
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
  [../]
[]


[BCs]
  # rotate:
  # ynew = c*y + s*z.  znew = -s*y + c*z
  [./bottomx]
    type = FunctionPresetBC
    variable = disp_x
    boundary = back
    function = '0'
  [../]
  [./bottomy]
    type = FunctionPresetBC
    variable = disp_y
    boundary = back
    function = '0*y+1*z-y'
  [../]
  [./bottomz]
    type = FunctionPresetBC
    variable = disp_z
    boundary = back
    function = '-1*y+0*z-z+if(t>0,0.5-y,0)' # note that this uses original nodal values of (x,y,z)
  [../]

  [./topx]
    type = FunctionPresetBC
    variable = disp_x
    boundary = front
    function = '0'
  [../]
  [./topy]
    type = FunctionPresetBC
    variable = disp_y
    boundary = front
    function = '0*y+1*z-y'
  [../]
  [./topz]
    type = FunctionPresetBC
    variable = disp_z
    boundary = front
    function = '-1*y+0*z-z+if(t>0,0.5-y,0)' # note that this uses original nodal values of (x,y,z)
  [../]
[]

[AuxVariables]
  [./stress_xz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_zx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_yz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_zz]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./yield_fcn]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./stress_xz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xz
    index_i = 0
    index_j = 2
  [../]
  [./stress_zx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zx
    index_i = 2
    index_j = 0
  [../]
  [./stress_yz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yz
    index_i = 1
    index_j = 2
  [../]
  [./stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
  [../]
  [./yield_fcn_auxk]
    type = MaterialStdVectorAux
    property = plastic_yield_function
    index = 0
    variable = yield_fcn
  [../]
[]

[Postprocessors]
  [./s_xz]
    type = PointValue
    point = '0 0 0'
    variable = stress_xz
  [../]
  [./s_yz]
    type = PointValue
    point = '0 0 0'
    variable = stress_yz
  [../]
  [./s_zz]
    type = PointValue
    point = '0 0 0'
    variable = stress_zz
  [../]
  [./f]
    type = PointValue
    point = '0 0 0'
    variable = yield_fcn
  [../]
[]

[UserObjects]
  [./coh]
    type = TensorMechanicsHardeningConstant
    value = 1
  [../]
  [./tanphi]
    type = TensorMechanicsHardeningConstant
    value = 0.5
  [../]
  [./tanpsi]
    type = TensorMechanicsHardeningConstant
    value = 0.1111077
  [../]
  [./wps]
    type = TensorMechanicsPlasticWeakPlaneShear
    cohesion = coh
    tan_friction_angle = tanphi
    tan_dilation_angle = tanpsi
    smoother = 0.5
    yield_function_tolerance = 1E-6
    internal_constraint_tolerance = 1E-6
  [../]
[]

[Materials]
  [./mc]
    type = FiniteStrainMultiPlasticity
    block = 0
    disp_x = disp_x
    disp_y = disp_y
    disp_z = disp_z
    fill_method = symmetric_isotropic
    C_ijkl = '0 1E6'
    plastic_models = wps
    transverse_direction = '0 0 1'
    ep_plastic_tolerance = 1E-5
    debug_fspb = 1
  [../]
[]


[Executioner]
  start_time = -1
  end_time = 1
  dt = 1
  type = Transient
[]


[Outputs]
  file_base = large_deform1
  output_initial = true
  print_linear_residuals = true
  print_perf_log = true
  [./csv]
    type = CSV
    interval = 1
  [../]
  [./exodus]
    type = Exodus
    interval = 1
  [../]
[]
