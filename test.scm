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
		(rl/draw-rectangle 
			(fvec4-mk (fvec2.x anchor) (fvec2.y anchor) (fvec2.x size) (fvec2.y size))
			(colr-mk 255 0 0 128)
		)
	)
)

(define* (update)
	(let 
		( ;; let variables
			(height 20) ( w 120 ) ( h 60 )
			(mpos (rl/get-mouse-pos))
		)
		(let ((draw-rct (lambda (colr) (rl/draw-rectangle (fvec4-mk 20 height w h) colr) (+ h 20))))
			(let ((push-rct (lambda (colr) (set! height (+ height (draw-rct colr))))))
				(push-rct red)
				(push-rct (colr-mk 255 0 0))
				(push-rct white)
				(push-rct red)
				(push-rct red)
				(push-rct red)
			)
		)
		(rl/draw-rectangle (fvec4-mk 80 80 120 120) white)
		(draw-star mpos (fvec2-mk 80 80) white)
		;; (rl/draw-texture tex-star (tex-rect tex-star) (fvec4-mk (fvec2.x mpos) (fvec2.y mpos) 60 60) (fvec2-mk 0 0) 0 white)
	)
	(set! gtime (+ gtime (/ 1.0 60.0)))
)

(define pa (fvec2-mk 1 2))
(define pb (fvec2-mk 100 100))


(display (linalg/vec2-scale pa 6))
