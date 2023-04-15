(define-package "org2web" "20210203.324" "A static site generator based on org mode."
  '((cl-lib "1.0")
    (ht "1.5")
    (mustache "0.22")
    (htmlize "1.47")
    (org "8.0")
    (dash "2.0.0")
    (el2org "0.10")
    (simple-httpd "0.1"))
  :commit "6f5c5f0cc5c877ac3a383782bbe8751264d807b6" :authors
  '(("Feng Shu  <tumashu AT 163.com>")
    ("Jorge Javier Araya Navarro <elcorreo AT deshackra.com>")
    ("Kelvin Hu <ini DOT kelvin AT gmail DOT com>"))
  :maintainer
  '("Feng Shu  <tumashu AT 163.com>")
  :keywords
  '("org-mode" "convenience" "beautify")
  :url "https://github.com/tumashu/org2web")
;; Local Variables:
;; no-byte-compile: t
;; End:
