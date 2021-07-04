package hcb;

enum PauseState {
    Idle;
    Resume;
    Inherit(pauseable: Pauseable);
}

typedef Pauseable = {
    pauseState: PauseState
}

class Pause {
    public static inline function updateOnPause(p: Pauseable): Bool {
        switch (p.pauseState) {
            case Idle:
                return false;
            case Resume:
                return true;
            case Inherit(pauseable):
                if(pauseable == p)
                    throw "Infinite loop found with recursive \'Inherit\' pause states";

                return updateOnPause(pauseable);
        }
    }
}