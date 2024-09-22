from pyromat import*

# Get the steam properties from the multiphase water model

config["unit_pressure"] = "bar"
config["unit_temperature"]="C"
prop_water=get('mp.H2O')


# Initial properties at the boiler
p_boiler = 150
T_boiler = 500

#Calculate properties at State 1 (after the boiler)
h1 = prop_water.h(p=p_boiler, T=T_boiler)
s1 = prop_water.s(p=p_boiler, T=T_boiler)

# Define the pressure at the condenser
p_condenser = 10

# Calculate isentropic state properties at State 2 (after the turbine)
h2 = prop_water.h(p=p_condenser, s=s1)
s2 = prop_water.s(p=p_condenser, s=s1)

# Apply turbine efficiency to find actual h2
# eta_turbine = 0.85
# h2 = h1 - eta_turbine * (h1 - h2s)

# Calculate properties at State 3 (after the condenser, saturated liquid)
# Here, we use the quality parameter x=0 for saturated liquid
h3 =prop_water.h(p=p_condenser, x=0)
s3 = prop_water.s(p=p_condenser, x=0)
v3 = prop_water.v(p=p_condenser, x=0)

# Calculate properties at State 4 (after the pump, back to boiler pressure)
# Using specific volume at State 3 to calculate enthalpy change at constant entropy

h4s = h3 + v3 * (p_boiler - p_condenser) * 1e3  # Assuming fluid is incompressible
eta_pump = 0.85
h4 = h3 + (h4s - h3) / eta_pump

# Print results
print(f"State 1: h1 = {h1} kJ/kg, s1 = {s1} kJ/kgK")
print(f"State 2: h2 = {h2} kJ/kg, s2 = {s2} kJ/kgK")
print(f"State 3: h3 = {h3} kJ/kg, s3 = {s3} kJ/kgK")
print(f"State 4: h4 = {h4} kJ/kg, s4 = {s3} kJ/kgK") 
