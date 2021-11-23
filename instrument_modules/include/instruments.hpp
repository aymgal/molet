#ifndef INSTRUMENT_HPP
#define INSTRUMENT_HPP

#include <string>
#include "json/json.h"

class RectGrid;
class BaseNoise;

class offsetPSF {
public:
  int offset_image;
  int offset_cropped;
  int nj;
  int ni;

  void print();
  void printFrame(FILE* fh,int Nx,int Ny,double xmin,double xmax,double ymin,double ymax);
};

class Instrument {
public:
  static std::string path;
  std::string name;
  double lambda_min; // in nm
  double lambda_max; // in nm
  double resolution; // in arcsec
  double readout;    // in electrons
  double ZP;
  
  RectGrid* original_psf = NULL;
  RectGrid* scaled_psf   = NULL;
  RectGrid* cropped_psf  = NULL;
  double* kernel         = NULL;
  BaseNoise* noise       = NULL;

  Instrument(std::string name,Json::Value noise_pars);
  Instrument(std::string name,double ZP,Json::Value noise_pars);
  ~Instrument();

  void common_constructor(Json::Value noise_pars);
  static double getResolution(std::string name);
  std::string getName();
  void interpolatePSF(RectGrid* grid);
  void cropPSF(double threshold);
  void createKernel(int Nx,int Ny);
  void convolve(RectGrid* grid);
  offsetPSF offsetPSFtoPosition(double x,double y,RectGrid* grid);

  void replacePSF(std::string path_to_file);
  void preparePSF(RectGrid* grid,double ratio);
  double sumPSF(offsetPSF* psf_offset);
};

#endif /* INSTRUMENT_HPP */
