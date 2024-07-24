from scipy import stats
import pulp as pl
from pulp import *
import pandas as pd
import numpy as np
#import clpex

# load numpy array from npy file
from numpy import load
# save numpy array as npy file
from numpy import asarray
from numpy import save


# ['GLPK_CMD', 'PYGLPK', 'CPLEX_CMD', 'CPLEX_PY', 'CPLEX_DLL', 'GUROBI', 'GUROBI_CMD', 'MOSEK', 'XPRESS', 'PULP_CBC_CMD', 'COIN_CMD', 'COINMP_DLL', 'CHOCO_CMD', 'MIPCL_CMD', 'SCIP_CMD']

n_breeders = 300
n_processors = 500
solver_list = pl.listSolvers(onlyAvailable=True)
print(solver_list)

# Cost Matrix

cost_matrix = np.array([[1, 3, 0.5, 4], 
                       [2.5, 5, 1.5, 2.5]])



readFile = "False"
#print(cost_matrix)

if readFile == "False":     
    carbon_emissions_cost = []
    for i in range(n_breeders):
        #newArray = np.random.rand(2, 15, size=(1, 10))
        # ran_floats = np.round(np.array((np.random.uniform(2,15,10))),3)
        ran_floats = np.round(np.random.uniform(4000, 9000, n_processors), n_breeders)
        carbon_emissions_cost.append(ran_floats)
        #ran_floats = [np.random.uniform(2, 15) for j in range(10)]
        #carbon_emissions = np.insert(carbon_emissions, [i], np.array(ran_floats), axis=0)
    carbon_emissions_cost = np.asarray(carbon_emissions_cost)
    data = asarray(carbon_emissions_cost)
    save('./examples/carbonOptimization/carbon_emissions_cost.npy', data)
    #print(carbon_emissions_cost)
else:
    carbon_emissions_cost = load('./examples/carbonOptimization/carbon_emissions_cost.npy')
    #print(carbon_emissions_cost) 
 
print("Carbon Emission Cost Matrix Statsitics") 
#print(carbon_emissions_cost)    
    #print(type(carbon_emissions_cost))
    #print(stats.describe(carbon_emissions_cost))
print('np.mean',np.mean(carbon_emissions_cost))
print('np.average',np.average(carbon_emissions_cost))
print('np.std',np.std(carbon_emissions_cost))
print('np.var',np.var(carbon_emissions_cost))
    # print('np.cov',np.cov(carbon_emissions_cost))
    #print('np.correlate',np.correlate(carbon_emissions_cost))
print('np.median',np.median(carbon_emissions_cost))
    #print('np.percentile',np.percentile(carbon_emissions_cost))
    #print('np.corrcoef',np.corrcoef(carbon_emissions_cost))
print("Carbon Emission Cost Matrix Statsitics") 

"""
carbon_emissions_cost = []
for i in range(n_processors):
    #newArray = np.random.rand(2, 15, size=(1, 10))
    # ran_floats = np.round(np.array((np.random.uniform(2,15,10))),3)
    ran_floats = np.round(np.random.uniform(2, 15, 10), 3)
    carbon_emissions_cost.append(ran_floats)
    #ran_floats = [np.random.uniform(2, 15) for j in range(10)]
    #carbon_emissions = np.insert(carbon_emissions, [i], np.array(ran_floats), axis=0)
   
carbon_emissions_cost = np.asarray(carbon_emissions_cost)
data = asarray(carbon_emissions_cost)
save('carbon_emissions_cost.npy', data)
print(carbon_emissions_cost)
#newArray = np.random.rand(2, 15, size=(5, 10))
"""
# save to npy file


# Demand Matrix
if readFile == "False":     
    processor_demand = np.array(np.round(np.random.uniform(10000, 15000, n_processors ), 1))
    data = asarray(processor_demand)
    save('./examples/carbonOptimization/processor_demand.npy', data)
    #print(data)
else:
    processor_demand = load('./examples/carbonOptimization/processor_demand.npy')
    #print("processor_demand_matrix:", processor_demand)
print("Processor Demand Matrix Statsitics") 
#print(processor_demand)
    #print(type(carbon_emissions_cost))
    #print(stats.describe(carbon_emissions_cost))
print('np.mean',np.mean(processor_demand))
print('np.average',np.average(processor_demand))
print('np.std',np.std(processor_demand))
print('np.var',np.var(processor_demand))
    # print('np.cov',np.cov(carbon_emissions_cost))
    #print('np.correlate',np.correlate(carbon_emissions_cost))
print('np.median',np.median(processor_demand))
    #print('np.percentile',np.percentile(carbon_emissions_cost))
    #print('np.corrcoef',np.corrcoef(carbon_emissions_cost))

print("Processor Demand Matrix Statsitics") 


# Supply Matrix
if readFile == "False": 
    breeder_supply = np.array(np.round(np.random.uniform(20000, 40000, n_breeders ), 1))
    data = asarray(breeder_supply)
    save('./examples/carbonOptimization/breeder_supply.npy', data)
    #print(data)
else: 
    breeder_supply = load('./examples/carbonOptimization/breeder_supply.npy')
    #print("breeder_supply_matrix:", breeder_supply)

print("Breeder Supply Matrix Statsitics") 
    #print(type(carbon_emissions_cost))
    #print(stats.describe(carbon_emissions_cost))
#print(breeder_supply)
print('np.mean',np.mean(breeder_supply))
print('np.average',np.average(breeder_supply))
print('np.std',np.std(breeder_supply))
print('np.var',np.var(breeder_supply))
    # print('np.cov',np.cov(carbon_emissions_cost))
    #print('np.correlate',np.correlate(carbon_emissions_cost))
print('np.median',np.median(breeder_supply))
    #print('np.percentile',np.percentile(carbon_emissions_cost))
    #print('np.corrcoef',np.corrcoef(carbon_emissions_cost))

print("Breeder Supply Matrix Statsitics") 

  
"""
processor_demand = np.array(np.round(np.random.uniform(5000, 10000, 10), 1))
print(processor_demand)
# Demand Matrix
cust_demands = np.array([35000, 22000, 18000, 30000])
print(cust_demands)

# Supply Matrix
processor_supply = np.array(np.round(np.random.uniform(15000, 20000, 5), 1))
warehouse_supply = np.array([60000, 80000])
"""

model = LpProblem("Breeder-Processor-Problem", LpMinimize)
#model = LpProblem("Supply-Demand-Problem", LpMinimize)

temp_variable = []
for i in range(1, n_breeders+1):
    for j in range(1, n_processors+1):
        var = str(i)+'_'+str(j)
        temp_variable.append(var)
#temp_variable.sort()
#temp_variable1 = np.asarray(temp_variable1)
#print("temp_array:", temp_variable)


variable_names = [str(i)+'_'+str(j) for j in range(1, n_processors+1) for i in range(1, n_breeders+1)]
#print(variable_names)
#variable_names = [str(i)+str(j) for j in range(1, n_customers+1) for i in range(1, n_warehouses+1)]
variable_names.sort()
#print("Variable Indices:", variable_names)


DV_variables = LpVariable.matrix("X", temp_variable, cat = "Integer", lowBound= 0 )
allocation = np.array(DV_variables).reshape(n_breeders ,n_processors )
print("Decision Variable/Allocation Matrix: ")
#print(allocation)


obj_func = lpSum(allocation*carbon_emissions_cost)
#print(obj_func)
model +=  obj_func
#print(model)



#Supply Constraints

for i in range(n_breeders):
    #print(lpSum(allocation[i][j] for j in range(n_processors)) <= breeder_supply[i])
    model += lpSum(allocation[i][j] for j in range(n_processors)) <= breeder_supply[i] , "Supply Constraints " + str(i)



#for i in range(n_warehouses):
   # print(lpSum(allocation[i][j] for j in range(n_customers)) <= warehouse_supply[i])
  #  model += lpSum(allocation[i][j] for j in range(n_customers)) <= warehouse_supply[i] , "Supply Constraints " + str(i)


# Demand Constraints

for j in range(n_processors):
    #print(lpSum(allocation[i][j] for i in range(n_breeders)) >= processor_demand[j])
    model += lpSum(allocation[i][j] for i in range(n_breeders)) >= processor_demand[j] , "Demand Constraints " + str(j)


#for j in range(n_customers):
 #   print(lpSum(allocation[i][j] for i in range(n_warehouses)) >= cust_demands[j])
  #  model += lpSum(allocation[i][j] for i in range(n_warehouses)) >= cust_demands[j] , "Demand Constraints " + str(j)

#print(model)

model.writeLP("Supply_demand_prob.lp")

#model.solve()
# ['GLPK_CMD', 'PYGLPK', 'CPLEX_CMD', 'CPLEX_PY', 'CPLEX_DLL', 'GUROBI', 'GUROBI_CMD', 'MOSEK', 'XPRESS', 'PULP_CBC_CMD', 'COIN_CMD', 'COINMP_DLL', 'CHOCO_CMD', 'MIPCL_CMD', 'SCIP_CMD']

#['GLPK_CMD', 'PYGLPK', 'CPLEX_CMD', 'CPLEX_PY', 'GUROBI', 'GUROBI_CMD', 'MOSEK', 'XPRESS', 'XPRESS', 'XPRESS_PY', 'PULP_CBC_CMD', 'COIN_CMD', 'COINMP_DLL', 'CHOCO_CMD', 'MIPCL_CMD', 'SCIP_CMD', 'HiGHS_CMD']


result = model.solve(PULP_CBC_CMD())
#result = model.solve(COIN_CMD())

#result = model.solve(CPLEX_PY())

#result = model.solve(GUROBI_CMD(keepFiles=True))

#result = model.solve(PULP_CBC_CMD(msg=False))


print("MODEL DETAILS HERE:")
status =  LpStatus[model.status]

print(status)

print("Total Cost:", model.objective.value())

# Decision Variables

i = 0 
j = 0
k = 0
l = 0

for v in model.variables():
    k += 1
    try:
        #print(v.name,"=", v.value())
        if v.value() == 0:
            i += 1
        else:
            j += 1
        #l = v.mean()
    except:
        print("error couldnt find the required value")

print('total variables:', k , 'not assigned variables:', i, 'assigned variables:', j, 'mean', l)



"""
for i in range(n_breeders):
    print("Breeder ", str(i+1))
    print(lpSum(allocation[i][j].value() for j in range(n_processors)))

"""

print(result)
