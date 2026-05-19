class Cie10Item {
  const Cie10Item(this.codigo, this.descripcion, this.area);

  final String codigo;
  final String descripcion;
  final String area;
}

const catalogoCie10 = [
  Cie10Item('G47.3', 'Apnea del sueno', 'AOS'),
  Cie10Item('R06.83', 'Ronquido', 'AOS'),
  Cie10Item('R13.10', 'Disfagia no especificada', 'DISFAGIA'),
  Cie10Item('R13.12', 'Disfagia orofaringea', 'DISFAGIA'),
  Cie10Item('J69.0', 'Neumonia por aspiracion', 'DISFAGIA'),
  Cie10Item('R47.01', 'Afasia adquirida', 'AFASIA'),
  Cie10Item('R47.1', 'Disartria y anartria', 'AFASIA'),
  Cie10Item('I69.391', 'Afasia posterior a ACV hemorragico', 'AFASIA'),
  Cie10Item('F80.0', 'Trastorno del desarrollo del habla-articulacion', 'LENGUAJE'),
  Cie10Item('F80.1', 'Trastorno expresivo del lenguaje', 'LENGUAJE'),
  Cie10Item('F80.2', 'Trastorno receptivo del lenguaje', 'LENGUAJE'),
  Cie10Item('F84.0', 'Trastorno del espectro autista', 'LENGUAJE'),
  Cie10Item('F81.0', 'Trastorno especifico de la lectura', 'APRENDIZAJE'),
  Cie10Item('F81.2', 'Trastorno de habilidades aritmeticas', 'APRENDIZAJE'),
  Cie10Item('F90.0', 'TDAH predominantemente inatento', 'APRENDIZAJE'),
  Cie10Item('F90.2', 'TDAH tipo combinado', 'APRENDIZAJE'),
];
