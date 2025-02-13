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

(define records (list))
(define* (record-mk name description keepday)
	(if (and (string? name) (string? description) (integer? keepday))
		(cons name (vec-mk description keepday))
		#f
	)
)
(define-macro (listpush -thelist . body)
	`(set! ,-thelist (append ,-thelist (list ,@body)))
)
(define* (record.name record)
	(car record)
)

;; list 里的每一个元素都是pair，如果往里面append一个不是pair的元素，它就不再是一个list了

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

(define debug-texts '())
(define* (push-debug-text message) 
	( set! debug-texts (append debug-texts message) )
)

(define* (update)
	(let ((dbg-texts (list)))
		(let 
			( ;; let variables
				(height 20) ( w 120 ) ( h 60 )
				(mpos (rl/get-mouse-pos))
				(velocity 6)
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
			(for-each (lambda (x) (push-debug-text (object->string x))) records)
			(let ((text-stack 30)) ;; draw debug texts
				(for-each (lambda (x)
					(rl/draw-text x (fvec2-mk 28 (+ text-stack 2)) 32 1 (colr-mk 0 0 0 128)) 
					(rl/draw-text x (fvec2-mk 30 text-stack) 32 1 (colr-mk 0 255 0)) 
					(set! text-stack (+ text-stack 36))
				) debug-texts)
			)
			;; (rl/draw-text (object->string debug-texts) (fvec2-mk 30 30) 32 1 (colr-mk 0 255 0)) 
			(set! dragging (rl/get-mousebtn-down "L"))
			(draw-star star-pos (fvec2-mk 80 80) white)
			(eval draw-text)
			(set! gtime (+ gtime dt))
		)
	)
)


(display (linalg/vec2-scale pa 6))
