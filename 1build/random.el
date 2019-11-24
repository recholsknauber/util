;; Walking through eintr
(length '(1 2 3))
'(this is a quoted list)

(car '(olivia liam ryan))
(cdr '(olivia liam ryan))
(cons 'pine '(fir oak maple))

(nthcdr 3 '(pine fir oak maple))
(nthcdr 4 '(pine fir oak maple))

(nth 0 '(olivia liam ryan))
(nth 2 '(olivia liam ryan))

(setq fam '(olivia liam ryan))
fam
(setcar fam 'doofus)
fam

(defun foo (a b c) (/ a b c))
(foo 1 2 3)

(cons "another place"
      '("a piece of text" "previous piece"))

(setq birdteams '(ravens seahawks))
birdteams
(setq morebirdteams '(eagles falcons cardinals))
(setq allbirdteams (append morebirdteams birdteams))
(setcdr allbirdteams '(cowboys giants redskins))
allbirdteams
(setcar allbirdteams 'losers)
allbirdteams

(zap-to-char
