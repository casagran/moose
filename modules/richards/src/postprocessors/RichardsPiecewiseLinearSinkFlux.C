/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/


//  This post processor returns the mass due to a flux from the boundary of a volume.
//
#include "RichardsPiecewiseLinearSinkFlux.h"
#include "Function.h"

template<>
InputParameters validParams<RichardsPiecewiseLinearSinkFlux>()
{
  InputParameters params = validParams<SideIntegralVariablePostprocessor>();
  params.addRequiredParam<bool>("use_mobility", "If true, then fluxes are multiplied by (density*permeability_nn/viscosity), where the '_nn' indicates the component normal to the boundary.  In this case bare_flux is measured in Pa.s^-1.  This can be used in conjunction with use_relperm.");
  params.addRequiredParam<bool>("use_relperm", "If true, then fluxes are multiplied by relative permeability.  This can be used in conjunction with use_mobility");
  params.addRequiredParam<std::vector<Real> >("pressures", "Tuple of pressure values.  Must be monotonically increasing.");
  params.addRequiredParam<std::vector<Real> >("bare_fluxes", "Tuple of flux values (measured in kg.m^-2.s^-1 for use_mobility=false, and in Pa.s^-1 if use_mobility=true).  A piecewise-linear fit is performed to the (pressure,bare_fluxes) pairs to obtain the flux at any arbitrary pressure.  If a quad-point pressure is less than the first pressure value, the first bare_flux value is used.  If quad-point pressure exceeds the final pressure value, the final bare_flux value is used.  This flux is OUT of the medium: hence positive values of flux means this will be a SINK, while negative values indicate this flux will be a SOURCE.");
  params.addRequiredParam<UserObjectName>("richardsVarNames_UO", "The UserObject that holds the list of Richards variable names.");
  params.addParam<FunctionName>("multiplying_fcn", 1.0, "The flux will be multiplied by this spatially-and-temporally varying function.  This is useful if the boundary is a moving boundary controlled by RichardsExcav.");
  params.addClassDescription("Records the fluid flow into a sink (positive values indicate fluid is flowing from porespace into the sink).");
  return params;
}

RichardsPiecewiseLinearSinkFlux::RichardsPiecewiseLinearSinkFlux(const std::string & name, InputParameters parameters) :
    SideIntegralVariablePostprocessor(name, parameters),
    _sink_func(getParam<std::vector<Real> >("pressures"), getParam<std::vector<Real> >("bare_fluxes")),

    _use_mobility(getParam<bool>("use_mobility")),
    _use_relperm(getParam<bool>("use_relperm")),

    _m_func(getFunction("multiplying_fcn")),

    _richards_name_UO(getUserObject<RichardsVarNames>("richardsVarNames_UO")),
    _pvar(_richards_name_UO.richards_var_num(_var.number())),

    _pp(getMaterialProperty<std::vector<Real> >("porepressure")),

    _viscosity(getMaterialProperty<std::vector<Real> >("viscosity")),
    _permeability(getMaterialProperty<RealTensorValue>("permeability")),
    _rel_perm(getMaterialProperty<std::vector<Real> >("rel_perm")),
    _density(getMaterialProperty<std::vector<Real> >("density"))
{}

Real
RichardsPiecewiseLinearSinkFlux::computeQpIntegral()
{
  Real flux = _sink_func.sample(_pp[_qp][_pvar]);

  flux *= _m_func.value(_t, _q_point[_qp]);

  if (_use_mobility)
  {
    Real k = (_permeability[_qp]*_normals[_qp])*_normals[_qp];
    flux *= _density[_qp][_pvar]*k/_viscosity[_qp][_pvar];
  }
  if (_use_relperm)
    flux *= _rel_perm[_qp][_pvar];

  return flux*_dt;
}
