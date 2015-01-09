
# Step 1: Define the sets
set SOURCES;
set CUSTOMERS;

# Step 2: Define parameters. Note the use of checks and defaults values.
param Demand {CUSTOMERS} >= 0;
param Supply {SOURCES}   >= 0;
param T {CUSTOMERS, SOURCES} default 1000;

# Step 3: Define the decision variables
var x {CUSTOMERS, SOURCES} >= 0;

# Step 4: Write the objective
minimize Cost: sum{c in CUSTOMERS, s in SOURCES} T[c,s]*x[c,s];

# Step 5: Write the constraints
subject to SRC {s in SOURCES}: sum {c in CUSTOMERS} x[c,s] <= Supply[s];
subject to DST {c in CUSTOMERS}: sum {s in SOURCES} x[c,s] = Demand[c];

# Step 6: Call for a solution
solve;

# Step 7: Write results to .csv files
printf "\nTotal Cost = %7.2f\n\n", Cost;

table shiptable {c in CUSTOMERS, s in SOURCES} OUT "CSV" "ship.csv" :
    c~Customer, s~Source, x[c,s]~Quantity, x[c,s].dual~Marginal, T[c,s]*x[c,s]~Cost;

table sources {s in SOURCES} OUT "CSV" "source.csv" :
    s~Source, Supply[s]~Supply, SRC[s]~Activity, SRC[s].dual~Marginal;
    
table customers {c in CUSTOMERS} OUT "CSV" "customer.csv" :
    c~Customer, Demand[c]~Demand, DST[c]~Activity, DST[c].dual~Marginal;

end;
