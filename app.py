import pyromat as pm

# Configure PyroMat units
pm.config['unit_pressure'] = 'bar'  # Pressure in bar
pm.config['unit_temperature'] = 'C'  # Temperature in Celsius
pm.config['unit_energy'] = 'kJ'      # Energy in kJ

# Get the water properties
water = pm.get('mp.H2O')

# Stage 1: Boiler to Turbine
P_boiler = 150  # Pressure at boiler in bar
T_turbine_inlet = 500  # Temperature at turbine inlet in Celsius
h_boiler = water.h(T=T_turbine_inlet, p=P_boiler)
s_boiler = water.s(T=T_turbine_inlet, p=P_boiler)

# Stage 2: Turbine to Condenser
P_condenser = 10  # Pressure at condenser in bar
h2s = water.h(s=s_boiler, p=P_condenser)  # Isentropic enthalpy at condenser pressure
eta_turbine = 0.85  # Turbine efficiency
h_turbine_exit = h_boiler - eta_turbine * (h_boiler - h2s)
s_turbine_exit = water.s(h=h_turbine_exit, p=P_condenser)
T_turbine_exit = water.T(h=h_turbine_exit, p=P_condenser)

# Stage 3: Condenser to Pump
# Assuming complete condensation at condenser pressure
h_condenser = water.hs(p=P_condenser)[0]  
s_condenser = water.s(h=h_condenser, p=P_condenser)
T_condenser = water.T(h=h_condenser, p=P_condenser)

# Stage 4: Pump to Boiler
# Assuming isentropic compression by the pump
P_boiler_return = P_boiler  
s_pump_exit = s_condenser  
h_pump_exit = water.h(s=s_pump_exit, p=P_boiler_return)
eta_pump = 0.85  
h_pump_work = (h_pump_exit - h_condenser) / eta_pump
h_pump_actual = h_condenser + h_pump_work
T_pump_exit = water.T(h=h_pump_actual, p=P_boiler_return)

print(f"Stage 1: Boiler to Turbine\nPressure: ",P_boiler," bar, Temperature: ",T_turbine_inlet,"°C, Enthalpy: ",h_boiler," kJ/kg, Entropy: ",s_boiler," kJ/kg/K")
print(f"Stage 2: Turbine to Condenser\nPressure: ",P_condenser," bar, Exit Temp: ",T_turbine_exit," °C, Enthalpy Exit: ",h_turbine_exit," kJ/kg, Entropy Exit: ",s_turbine_exit, "kJ/kg/K")
print(f"Stage 3: Condenser\nPressure: ",P_condenser," bar, Temp: ",T_condenser," °C, Enthalpy: ",h_condenser," kJ/kg, Entropy: ",s_condenser," kJ/kg/K")
print(f"Stage 4: Pump to Boiler\nPressure: ",P_boiler_return," bar, Temp Exit: ",T_pump_exit," °C, Enthalpy Exit: ",h_pump_actual," kJ/kg")

