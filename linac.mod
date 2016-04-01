#%%writefile LinacSchedule.mod

/* big number for disjuctive constraints */
param K := 24*60;

/* setup time between patients */
param setup;

/* set of linac machines and capabilities */
set LINACS dimen 2;
set L := setof{(l,c) in LINACS} l;
set C := setof{(l,c) in LINACS} c;
param hasCapability{l in L, c in C} := if (l,c) in LINACS then 1 else 0;

/* LINAC start and finish times, minutes after midnight */
param lStart{L} > 0;
param lFinish{L} > 0;

/* patient properties */
set P;
param dur{P} > 0;       /* duration in minutes */
param rel{P} > 0;       /* earlist patient availability */
param due{P} > 0;       /* latest patient availability */
param reqCapability{P, C} >= 0, binary;

/* patient time conflicts */
set TIMES;
param patient{TIMES};
param wStart{TIMES};
param wFinish{TIMES};

/* assignment of each patient to one linac with needed capabilities */
var lp{P, L} >= 0, binary;

s.t. assign{p in P}: sum{l in L} lp[p, l] <= 1;
    
s.t. capabilities{p in P, l in L, c in C}: 
    lp[p, l] * hasCapability[l, c] >= lp[p, l] * reqCapability[p, c];
    
/* schedule patient within patient and machine availability */
var x{P} >= 0;
var pastdue{P} >= 0;

s.t. startP{p in P}: x[p] >= rel[p];
s.t. endP{p in P}: x[p] + dur[p] <= due[p] + pastdue[p];
s.t. startL{p in P, l in L}: x[p] >= lStart[l] * lp[p,l];
s.t. endL{p in P, l in L}: x[p] + dur[p] <= K * (1 - lp[p,l]) + lFinish[l] * lp[p,l];

/* patient sequencing on each machine. seq[p,q] = 1 if p is before q  */
var seq{p in P, q in P, l in L : p < q}, binary;

s.t. p_after_q{p in P, q in P, l in L: p < q}:
    x[p] >= setup + (x[q] + dur[q]) - K * seq[p, q, l] 
                  - K * (1 - lp[p, l]) - K * (1 - lp[q, l]);

s.t. p_before_q{p in P, q in P, l in L: p < q}:
    x[q] >= setup + (x[p] + dur[p]) - K * (1 - seq[p, q, l]) 
                  - K * (1 - lp[p, l]) - K * (1 - lp[q, l]);

/* Soft contraints on exculsion windows */
var wEarly{i in TIMES} >= 0;
var wLate{i in TIMES} >= 0;
var ybin{i in TIMES} binary;   /* Choose to either shift left or shift right */

s.t. shiftEarly{i in TIMES}:
    wEarly[i] >= x[patient[i]] + dur[patient[i]] - wStart[i] - K * (1 - ybin[i]);
    
s.t. shiftLate{i in TIMES}:
    wLate[i] >= wFinish[i] - x[patient[i]] - K * ybin[i];

/* objective */
var z;
var y >= 0;
var penalty{p in P} >= 0;

s.t. hor{p in P} : x[p] + dur[p] <= y;

/* penalize any assignment that can't be made today's schedule */
s.t. infeasPenalty{p in P}: penalty[p] >= K * (1 - sum{l in L} lp[p,l]);
s.t. pastduePenalty{p in P}: penalty[p] >= pastdue[p];

/* the more times they want to avoid, the less we care about them */
param pWeight{p in P}, >= 0 := 10000 / (1 + sum{i in TIMES} if p = patient[i] then (wFinish[i] - wStart[i]) else 0);
s.t. timePenalty{i in TIMES}: penalty[patient[i]] >= (wEarly[i] + wLate[i]);

/* mixed norm objective */
s.t. sup{i in TIMES}: z >= penalty[patient[i]]*pWeight[patient[i]];

minimize obj: z + y + sum{p in P} penalty[p];

solve;

table tout {p in P, l in L : lp[p,l] == 1} OUT "CSV" "LinacSchedule.csv":
    p~Patient, l~Machine, x[p]~Start, x[p]+dur[p]~Finish;

#%%script glpsol -m LinacSchedule.mod -d /dev/stdin --out output

data;

/* machine name, capability pairs */
set LINACS :=
    LINAC1 IMRT
    LINAC2 VMAT
    LINAC2 MRI
;

/* linac availability. 600=10am, 480=8am */
param : lStart lFinish :=
    LINAC1   600   1200
    LINAC2   480   1200;
    
/* setup time required between patients */
param setup := 2;

/* number of minutes required to administer treatment */
param : P : dur rel due:=
     1   10   480   1200
     2   15   480   1200
     3   10   480   1200
     4   15   480   1200
     5   15   480   1200
     6   10   480   1200
     7   15   480   1200
     8   10   480   1200
     9   15   480   1200
    10   15   480   1200
    11   10   480   1200
    12   15   480   1200
    13   10   480   1200
    14   15   480   1200
    15   15   480   1200
;

param reqCapability : IMRT VMAT MRI :=
     1   0   1   0
     2   0   1   0
     3   0   1   0
     4   0   1   0
     5   1   0   0
     6   1   0   0
     7   1   0   0
     8   0   1   0
     9   0   1   0
    10   0   1   0
    11   1   0   0
    12   1   0   0
    13   1   0   0
    14   1   0   0
    15   1   0   0
;

/* ie: patient 1 should AVOID between midnight and 3pm */
param : TIMES : patient wStart wFinish :=
    1   1   800    900  
    2   4     0    604
    3   4   610   1500
;

end;

