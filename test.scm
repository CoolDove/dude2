(define* (hello-dove)
	(display "hello \"from dove")
)

(define tex-star (rl/load-texture "star.png"))

(define white (colr-mk 255 255 255))
(define red (colr-mk 255 0 0))
(define* (tex-rect tex)
	(fvec4-mk 0 0 (rl/tex2d.w tex) (rl/tex2d.h tex))
)

(define gtime 0.0)

(define dragging #t)
(define star-pos (fvec2-mk 0 0))

(define* (draw-star pos size tint)
	(let
		( (anchor (linalg/vec2-subtract pos (linalg/vec2-scale size 0.5))) )
		(rl/draw-texture tex-star 
			(tex-rect tex-star)
			(fvec4-mk (fvec2.x pos) (fvec2.y pos) (fvec2.x size) (fvec2.y size))
			;; (fvec2-mk 0 0)
			(linalg/vec2-scale size 0.5)
			(* gtime 60)
			tint
		)
		(if dragging (rl/draw-rectangle 
			(fvec4-mk (fvec2.x anchor) (fvec2.y anchor) (fvec2.x size) (fvec2.y size))
			(colr-mk 255 0 0 128)
		))
	)
)

(define* (update)
	(let 
		( ;; let variables
			(height 20) ( w 120 ) ( h 60 )
			(mpos (rl/get-mouse-pos))
			(velocity 2)
			(dt (/ 1.0 60.0))

			(draw-text #f)
		)
		(if dragging
			(let
				(
					(distance (linalg/vec2-distance mpos star-pos))
					(d `(linalg/vec2-scale (linalg/vec2-subtract mpos star-pos) (* velocity dt)))
				)
				(if (> distance 0.5)
					(begin (set! star-pos (linalg/vec2-add star-pos (eval d)))
						(set! draw-text `(rl/draw-text (format #f " distance: ~G " ,distance) 
							(fvec2-mk 30 30) 32 1 (colr-mk 0 255 0))
						)
					)
				)
			)
		)

		(let ((draw-rct (lambda (colr) (rl/draw-rectangle (fvec4-mk 20 height w h) colr) (+ h 20))))
			(let ((push-rct (lambda (colr) (set! height (+ height (draw-rct colr))))))
				(push-rct red)
				(push-rct (colr-mk 128 255 0))
				(push-rct white)
				(push-rct red)
				(push-rct (colr-mk 128 60 233))
				(push-rct red)
			)
		)
		(rl/draw-rectangle (fvec4-mk 80 80 120 120) white)
		(set! dragging (rl/get-mousebtn-down "L"))
		(draw-star star-pos (fvec2-mk 80 80) white)

		(eval draw-text)
		(set! gtime (+ gtime dt))
	)
)

(define pa (fvec2-mk 1 2))
(define pb (fvec2-mk 100 100))


(display (linalg/vec2-scale pa 6))
