from flask import Flask, request, jsonify
import CoolProp.CoolProp as CP

app = Flask(__name__)

@app.route('/calculate', methods=['POST'])
def calculate():
    data = request.json
    component_type = data['component_type']
    P = data['pressure'] * 1e5  # Convert from bar to Pa
    T = data['temperature'] + 273.15  # Convert from °C to K
    efficiency = data.get('efficiency', 1)  # Default efficiency to 1 if not provided

    response = {}

    if component_type == 'turbine':
        # Turbine calculations
        h1 = CP.PropsSI('H', 'P', P, 'T', T, 'Water')
        s1 = CP.PropsSI('S', 'P', P, 'T', T, 'Water')
        P2 = data['exit_pressure'] * 1e5  # Assume exit pressure is provided
        h2s = CP.PropsSI('H', 'P', P2, 'S', s1, 'Water')
        h2 = h1 - (h1 - h2s) * efficiency
        response = {'enthalpy_out': h2}

    elif component_type == 'boiler':
        # Boiler calculations
        h_in = CP.PropsSI('H', 'P', P, 'Q', 0, 'Water')  # Saturated liquid
        h_out = CP.PropsSI('H', 'P', P, 'Q', 1, 'Water')  # Saturated vapor
        q_added = h_out - h_in
        response = {'heat_added': q_added}

    elif component_type == 'condenser':
        # Condenser calculations
        h_in = CP.PropsSI('H', 'P', P, 'Q', 1, 'Water')  # Saturated vapor
        h_out = CP.PropsSI('H', 'P', P, 'Q', 0, 'Water')  # Saturated liquid
        q_removed = h_in - h_out
        response = {'heat_removed': q_removed}

    elif component_type == 'pump':
        # Pump calculations (idealized as isentropic)
        s_in = CP.PropsSI('S', 'P', P, 'Q', 0, 'Water')
        P_out = data['exit_pressure'] * 1e5
        h2s = CP.PropsSI('H', 'P', P_out, 'S', s_in, 'Water')
        h1 = CP.PropsSI('H', 'P', P, 'Q', 0, 'Water')
        h2 = h1 + (h2s - h1) / efficiency
        response = {'enthalpy_out': h2}

    else:
        return jsonify({'error': 'Component type not supported'}), 400

    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
