# Octave Form


![fld demo](../master/demo.gif)

***

Forming limit diagram post-processing for ABAQUS, written in Octave.

## Forming Limit Curve

#### Marciniak–Kuczynski's Model
 ![\left(\dfrac{\bar{\varepsilon}^{\textsc{\tiny{A}}}}{\bar{\varepsilon}^{\textsc{\tiny{B}}}}\right)^{n}\left(\dfrac{\dot{\bar{\varepsilon}}^{\textsc{\tiny{A}}}}{\dot{\bar{\varepsilon}}^{\textsc{\tiny{B}}}}\right)^{m}=\frac{~^{\bar{\sigma}^{\textsc{\tiny{A}}}}\!\!/_{\sigma_{1}^{\textsc{\tiny{A}}}}}{~^{\bar{\sigma}^{\textsc{\tiny{B}}}}\!\!/_{\sigma_{1}^{\textsc{\tiny{B}}}}}~~\textrm{f}~e^{\left( \bar{\varepsilon}^{\textsc{A}}\frac{\partial\bar{\sigma}^{\textsc{A}}}{\partial\sigma_{1}^{\textsc{A}}} - \bar{\varepsilon}^{\textsc{B}}\frac{\partial\bar{\sigma}^{\textsc{B}}}{\partial\sigma_{1}^{\textsc{B}}} \right)}](../master/docs/mk.svg)