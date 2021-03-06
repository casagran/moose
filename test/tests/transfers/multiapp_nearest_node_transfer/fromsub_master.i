[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  # The Transfer system doesn't work quite right with ParallelMesh enabled.
  # Form more information, see #2126
  distribution = serial
[]

[Variables]
  [./u]
  [../]
[]

[AuxVariables]
  [./from_sub]
  [../]
  [./elemental_from_sub]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./diff]
    type = Diffusion
    variable = u
  [../]
[]

[BCs]
  [./left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 0
  [../]
  [./right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 1
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 1
  dt = 1

  # Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  output_initial = true
  exodus = true
  print_linear_residuals = true
  print_perf_log = true
[]

[MultiApps]
  [./sub]
    type = TransientMultiApp
    app_type = MooseTestApp
    positions = '0.48 0 0 -1.01 0 0'
    input_files = tosub_sub.i
  [../]
[]

[Transfers]
  [./from_sub]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_app = sub
    source_variable = u
    variable = from_sub
  [../]
  [./elemental_from_sub]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_app = sub
    source_variable = u
    variable = elemental_from_sub
  [../]
[]
