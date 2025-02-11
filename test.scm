(define* (hello-dove)
	(display "hello \"from dove")
)

(define* (update)
	(draw-rectangle 20 20 120 60 0 0 255 255)
	(draw-rectangle 20 (+ 20 80) 120 60 255 0 255 255)
	(draw-rectangle 40 (+ 20 80 80) 100 60 255 255 0 255)
)
