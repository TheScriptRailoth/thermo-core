from flask import Flask, request, jsonify
import pyromat as pm

app = Flask(__name__)

# Configure PyroMat units
pm.config['unit_pressure'] = 'bar'
pm.config['unit_temperature'] = 'C'
pm.config['unit_energy'] = 'kJ'

# Get the water properties
water = pm.get('mp.H2O')

@app.route('/')
def home():
    return "Welcome to the Rankine Cycle Calculator API!"

@app.errorhandler(Exception)
def handle_exception(e):
    """Handle unexpected server errors"""
    print("server")
    return jsonify({'error': 'Server Error', 'message': str(e)}), 500

@app.route('/calculate', methods=['POST', 'GET'])
def calculate():
    data = request.get_json()
    print(data)
    if not data:
        print("No data")
        return jsonify({'error': 'Missing JSON in request'}), 400

    required_keys = ['p_boiler', 'T_boiler', 'p_condenser', 'eta_turbine', 'eta_pump']
    missing_keys = [key for key in required_keys if key not in data]
    if missing_keys:
        print("Missing Key")
        return jsonify({'error': 'Missing parameters: ' + ', '.join(missing_keys)}), 400

    try:
        p_boiler = float(data['p_boiler'])
        T_boiler = float(data['T_boiler'])
        p_condenser = float(data['p_condenser'])
        eta_turbine = float(data['eta_turbine'])
        eta_pump = float(data['eta_pump'])

        states = rankine_cycle(p_boiler, T_boiler, p_condenser, eta_turbine, eta_pump)
        print(states)
        return jsonify(states) , 200
    except Exception as e:
        return jsonify({'error': str(e)}), 600
    
def rankine_cycle(p_boiler, T_boiler, p_condenser, eta_turbine=1, eta_pump=1):
    water = pm.get('mp.H2O')

    def get_properties(p, T=None, s=None, x=None):
        if x is not None:
            # Saturated state
            try:
                h = water.h(p=p, x=x).item()
                s = water.s(p=p, x=x).item()
                v = water.v(p=p, x=x).item()
                return (h, s, 'undefined', 'undefined', x, v)
            except Exception:
                return ('undefined', 'undefined', 'undefined', 'undefined', 'undefined', 'undefined')
        elif T is not None:
            # Superheated or subcooled state
            try:
                h = water.h(p=p, T=T).item()
                s = water.s(p=p, T=T).item()
                v = water.v(p=p, T=T).item()
                return (h, s, 'undefined', 'undefined', 'undefined', v)
            except Exception:
                return ('undefined', 'undefined', 'undefined', 'undefined', 'undefined', 'undefined')
        elif s is not None:
            # Isentropic expansion/compression
            try:
                h = water.h(p=p, s=s).item()
                return (h, s, 'undefined', 'undefined', 'undefined', 'undefined')
            except Exception:
                return ('undefined', 'undefined', 'undefined', 'undefined', 'undefined', 'undefined')
        return ('undefined', 'undefined', 'undefined', 'undefined', 'undefined', 'undefined')

    # State 1: Boiler exit (Superheated)
    h1, s1, hs1, ss1, x1, v1 = get_properties(p_boiler, T=T_boiler)

    # State 2: Turbine exit, isentropic expansion to condenser pressure
    h2, s2, hs2, ss2, x2, v2 = get_properties(p_condenser, s=s1)
    h2 = h1 - eta_turbine * (h1 - h2) if h2 != 'undefined' and h1 != 'undefined' else 'undefined'

    # State 3: Condenser exit (Saturated liquid)
    h3, s3, hs3, ss3, x3, v3 = get_properties(p_condenser, x=0)

    # State 4: Pump exit, isentropic compression back to boiler pressure
    h4s, s4, hs4, ss4, x4, v4 = get_properties(p_boiler, s=s3)
    h4 = h3 + (h4s - h3) / eta_pump if h4s != 'undefined' and h3 != 'undefined' else 'undefined'

    return {
        'State 1': {'h': h1, 's': s1, 'hs': hs1, 'ss': ss1, 'x': x1, 'v': v1},
        'State 2': {'h': h2, 's': s2, 'hs': hs2, 'ss': ss2, 'x': x2, 'v': v2},
        'State 3': {'h': h3, 's': s3, 'hs': hs3, 'ss': ss3, 'x': x3, 'v': v3},
        'State 4': {'h': h4, 's': s4, 'hs': hs4, 'ss': ss4, 'x': x4, 'v': v4},
    }

if __name__ == '__main__':
    app.run(debug=True)
