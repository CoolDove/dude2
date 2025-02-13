(define* (hello-dove)
	(display "hello \"from dove")
)

(define tex-star (rl/load-texture "star.png"))

(define game-act 1)
(define game-day 1)

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
(define* (record? record) (and (string? (car record)) ))
(define* (record.name record) (car record))

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
			(fvec4-mk (vec2.x pos) (vec2.y pos) (vec2.x size) (vec2.y size))
			;; (fvec2-mk 0 0)
			(linalg/vec2-scale size 0.5)
			(* gtime 60)
			tint
		)
		(if dragging (rl/draw-rectangle 
			(fvec4-mk (vec2.x anchor) (vec2.y anchor) (vec2.x size) (vec2.y size))
			(colr-mk 255 0 0 128)
		))
	)
)

(define debug-texts '())

(define* (update)
	(let 
		(
			(height 20) ( w 120 ) ( h 60 )
			(mpos (rl/get-mouse-pos))
			(velocity 6)
			(dt (/ 1.0 60.0))
			(draw-text #f)
			(scr-size (rl/get-screen-size))
		)
		(if (rl/gui-button "Press me" (fvec4-mk 300 200 260 40))
			(begin (display "Hello! Button (测测中文)") (newline) )
		)
		(if dragging
			(let
				(
					(distance (linalg/vec2-distance mpos star-pos))
					(d `(linalg/vec2-scale (linalg/vec2-subtract mpos star-pos) (* velocity dt)))
				)
				(if (> distance 0.5)
					(set! star-pos (linalg/vec2-add star-pos (eval d)))
				)
			)
		)

		(let ((button-stack 60))
			(for-each (lambda (x) 
				(listpush debug-texts (record.name x))
					(if (rl/gui-lbbutton (record.name x) (fvec4-mk 300 button-stack 280 40))
						(begin (display (record.name x)) (newline) )
					)
				(set! button-stack (+ button-stack 60))
			) records)
		)
		(let ((text-stack 30)) ;; draw debug texts
			(for-each (lambda (x)
				(if (string? x)
					(begin
						(rl/draw-text x (fvec2-mk 28 (+ text-stack 2)) 32 1 (colr-mk 0 0 0 128)) 
						(rl/draw-text x (fvec2-mk 30 text-stack) 32 1 (colr-mk 0 255 0)) 
						(set! text-stack (+ text-stack 36))
					)
				)
			) debug-texts)
			(set! debug-texts (list))
		)

		(let
			(
				(day-text (format #f "第 ~A 天" game-day))
				(size 32) (spacing 1) (color (colr-mk 128 200 0))
			)
			(let
				(
					(measure (rl/measure-text day-text size spacing))
				)
				(let
					(
						(x (math/center-in (vec2.x measure) (vec2.x scr-size)))
						(y 60)
					)
					(rl/draw-text day-text (fvec2-mk x y) size spacing color) 
				)
			)
		)
		(set! dragging (rl/get-mousebtn-down "L"))
		(draw-star star-pos (fvec2-mk 80 80) white)
		(rl/draw-triangle (fvec2-mk 60 60) (fvec2-mk 80 80) mpos white)
		(set! gtime (+ gtime dt))
	)
)

(define* (math/center-in a b)
	(- (* b 0.5) (* a 0.5))
)
