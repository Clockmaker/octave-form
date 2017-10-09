# Octave Form

* Deep drawing
![FLD demo](../master/demo_deepdrawing.gif)
![FLD legend](../master/legend.png)
* Hydroforming
![FLD demo](../master/demo_hydroforming.gif)
![FLD legend](../master/legend.png)

***

The Forming Limit Diagram (FLD) is a common tool in sheet metal forming.

The quality of the part is predicted by the strain imposed during the forming procedure.

## Forming Limit Curve
The forming limit curve (FLC)  determinated experimetally (e.g. ISO12004);
analytical methods are usually only used as a starting point.

`lib/flc.m` can be used to generate the FLC, based on Marciniak–Kuczynski's theory (M-K).


#### Marciniak–Kuczynski's Model

For the M-K's hyphothesis the fracture of the metal sheet is caused by inhomogeneities in its thickness.

 ![\left(\dfrac{\bar{\varepsilon}^{\textsc{\tiny{A}}}}{\bar{\varepsilon}^{\textsc{\tiny{B}}}}\right)^{n}\left(\dfrac{\dot{\bar{\varepsilon}}^{\textsc{\tiny{A}}}}{\dot{\bar{\varepsilon}}^{\textsc{\tiny{B}}}}\right)^{m}=\frac{~^{\bar{\sigma}^{\textsc{\tiny{A}}}}\!\!/_{\sigma_{1}^{\textsc{\tiny{A}}}}}{~^{\bar{\sigma}^{\textsc{\tiny{B}}}}\!\!/_{\sigma_{1}^{\textsc{\tiny{B}}}}}~~\textrm{f}~e^{\left( \bar{\varepsilon}^{\textsc{A}}\frac{\partial\bar{\sigma}^{\textsc{A}}}{\partial\sigma_{1}^{\textsc{A}}} - \bar{\varepsilon}^{\textsc{B}}\frac{\partial\bar{\sigma}^{\textsc{B}}}{\partial\sigma_{1}^{\textsc{B}}} \right)}](../master/docs/mk.svg)

````matlab
flc_mk(n, f, alpha, interactive, m, delta, fail, Ss, E1, E2)
````

...

By default the simulation uses the von Mises criterion, giving

![MK_vonMises](../master/docs/mk_mises.svg)

## Abaqus
* `.inp` are parsed using the function `abaqus_load` and supported elements are `S4/S4R`;
* `.rpt` are loaded using `abaqus_report`.

***
# References
Z. Marciniak, K. Kuczyński & T. Pokora.
"Influence of the plastic properties of a material on the forming limit diagram for sheet metal in tension".
Int. J. of Mech. Sci, Vol.15, pp.789-800, 1973.