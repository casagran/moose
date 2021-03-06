#ifndef CONSERVEDNOISEBASE_H
#define CONSERVEDNOISEBASE_H

#include "ConservedNoiseInterface.h"

//Forward Declarations
class ConservedNoiseBase;

template<>
InputParameters validParams<ConservedNoiseBase>();

/**
  * This Userobject is the base class of Userobjects that generate one
  * random number per timestep and quadrature point in a way that the integral
  * over all random numbers is zero. This can be used for a concentration fluctuation
  * kernel such as ConservedLangevinNoise, that keeps the total concenration constant.
  *
  * \see ConservedUniformNoise
  * \see ConservedNormalNoise
  */
class ConservedNoiseBase : public ConservedNoiseInterface
{
public:
  ConservedNoiseBase(const std::string & name, InputParameters parameters);

  virtual ~ConservedNoiseBase() {}

  virtual void initialize();
  virtual void execute();
  virtual void threadJoin(const UserObject & y);
  virtual void finalize();

  Real getQpValue(dof_id_type element_id, unsigned int qp) const;

protected:
  LIBMESH_BEST_UNORDERED_MAP<dof_id_type, std::vector<Real> > _random_data;
};

#endif //CONSERVEDNOISEBASE_H
