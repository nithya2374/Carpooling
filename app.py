from flask import Flask, render_template,  request, redirect , flash, session, jsonify, get_flashed_messages
import sqlite3
from werkzeug.security import check_password_hash,generate_password_hash
import time
from database import get_user_by_email  


app = Flask(__name__)
app.secret_key = "nithya17"  
db_name= "carpool.db"

@app.route('/')
def main():
    return render_template('main.html')


@app.route('/log',methods=['GET','POST'])
def log():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']


        if not email or not password:
            flash("Please enter email and password!", "danger")
            return redirect('/log')

        conn = sqlite3.connect(db_name)
        cursor = conn.cursor()

        cursor.execute("SELECT id,firstname, password FROM users WHERE email = ? ", (email,))
        user = cursor.fetchone()
        conn.close()

        if user and check_password_hash(user[2],password):
           
            session['user_id'] = user[0]  # Store user ID in session
            session['username'] = user[1]
            session['email'] = email

            if 'ride_search' in session:
                 return redirect('/ride_results')  # Back to search results
            return redirect('/home')
        
        else:
            flash("Invalid email or password!", "danger")
            return redirect('/log')
    
    return render_template('log.html')

@app.route('/sign',methods=['GET','POST'])
def sign():

    session.clear()

    if request.method == 'POST':
        firstname = request.form['firstname']
        lastname = request.form['lastname']
        email = request.form['email']
        password = request.form['password']
        contact = request.form['contact']
        confirm_password = request.form['confirm_password']
        role="user"
    

        if not (firstname and lastname and email and password and confirm_password and contact):
            flash("All fields are required!", "danger")
            return redirect('/sign')
            

        if password != confirm_password:
           flash("Passwords do not match!", "danger")
           return redirect('/sign')
        
        hashed_password = generate_password_hash(password)
           
    
        try:
          conn = sqlite3.connect(db_name)
          cursor = conn.cursor()

          cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
          if cursor.fetchone():
              flash("Email already registered! Try logging in.", "danger")
              return redirect('/sign')
            
          
          cursor.execute("INSERT INTO users (firstname, lastname, contact, email, password) VALUES (?,?,?, ?, ?)", 
                           (firstname, lastname, contact,email, hashed_password))
          conn.commit()
          conn.close()

          flash ("Signup successful!..Please Login to Continue ", "success")
          session.clear()
          return redirect('/log') 
        
        
        except sqlite3.IntegrityError:
           flash("Email already exists. Try logging in.", "danger")
           return redirect('/sign')

        finally:
           conn.close()
    
    return render_template('sign.html')


@app.route('/home',methods=['GET','POST'])
def home():
    return render_template('home.html')  # Show home page if logged in
    

@app.route('/offer',methods=['GET','POST'])
def offer():
    if request.method == 'POST':
        # Get form data
        source= request.form.get('source')
        destination= request.form.get('destination')
        date = request.form.get('date')
        time = request.form.get('time')
        seats= request.form.get('seats')
        via = request.form.get('via')
        ride_giver_id = session.get('username')

        if not ride_giver_id:
            return jsonify({'message': 'User not logged in.', 'success': False})    

        try:
            # Connect to database and insert ride data
            conn = sqlite3.connect('carpool.db')
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO ride (ride_giver_id, origin, destination, date, time, available_seats, via)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', ( ride_giver_id,source, destination, date, time, seats, via))
            conn.commit()
            conn.close()
            
            return jsonify({"success": True, "message" :" ✅ Ride offered successfully! "})
            
        
        except Exception as e:
            return jsonify({"success": False , "message" : "Failed to save ride."})
        
    return render_template('offer.html')

@app.route('/find',methods=['GET','POST'])
def find():
    if 'user_id' not in session:
        return redirect('/log')  # User must log in
    
    From = request.form.get('from')
    To = request.form.get('to')
    Date = request.form.get('date')
    Time = request.form.get('time')

    conn = sqlite3.connect('carpool.db')
    cursor = conn.cursor()
    cursor.execute("""
        SELECT * FROM ride
        WHERE origin = ? AND destination = ? AND date = ? AND time >= ?
    """, (From, To, Date, Time))
    rides = cursor.fetchall()
    conn.close()

    return render_template('find.html', rides=rides)
    

@app.route('/profile', methods=['GET','POST'])
def profile():
    
    if 'email' not in session:
        return redirect('/log')

    email = session['email']
    conn = sqlite3.connect('carpool.db')
    cursor = conn.cursor()
    cursor.execute("SELECT firstname, lastname, contact, email FROM users WHERE email = ?", (email,))
    user = cursor.fetchone()
    conn.close()

    user_data = {
        'firstname': user[0],
        'lastname': user[1],
        'contact': user[2],
        'email': user[3]
    }

    return render_template('profile.html', user=user_data)
    

@app.route('/update_profile', methods=['GET','POST'])
def update_profile():
     
    if 'email' not in session:
         return jsonify({'status': 'error', 'message': 'User not logged in'}), 401

    email = session['email']
    firstname = request.form.get('firstname','').strip()
    lastname = request.form.get('lastname','').strip()
    contact = request.form.get('mobile','').strip()
    password = request.form.get('password','').strip()
    
    if not firstname or not lastname or not contact:
        return jsonify({'status': 'error', 'message': 'Please fill in all required fields'}), 400


    try:
       conn = sqlite3.connect('carpool.db')
       cursor = conn.cursor()
 
       # Update basic info
       cursor.execute("""
           UPDATE users SET firstname = ?, lastname = ?, contact = ? WHERE email = ?
        """, (firstname, lastname, contact, email))
   
   
         # Update password if provided
       if password.strip():
        
          hashed_password = generate_password_hash(password)
          cursor.execute("""
               UPDATE users SET password = ? WHERE email = ?
           """, (hashed_password, email))

       conn.commit()
       return jsonify({'status': 'success', 'message': '✅ Profile updated successfully!'})

    except Exception as e:
        return jsonify({'status': 'error', 'message': 'Something went wrong'}), 500
    
    finally:
        conn.close()


@app.route('/ride_results', methods=['GET','POST'])
def ride_results():

    if 'user_id' not in session:

        if request.method == 'POST':
            session['ride_search'] = request.form.to_dict()
        flash("Please log in first!", "danger")
        return redirect('/log')
    
    # Retrieve saved search from session if redirected after login
    ride_data = session.pop('ride_search', None)
    form_data = ride_data if ride_data else request.form

    source = form_data.get('from')
    destination = form_data.get('to')
    date = form_data.get('date')  # optional

    conn = sqlite3.connect("carpool.db")
    cursor = conn.cursor()

    if date:
        cursor.execute("""
            SELECT 
                ride.origin, 
                ride.destination, 
                ride.date,
                ride.time, 
                ride.available_seats, 
                ride.via,
                users.firstname, 
                users.lastname, 
                users.contact
            FROM ride
            JOIN users ON ride.ride_giver_id = users.id
            WHERE ride.origin = ? AND ride.destination = ? AND ride.date = ?
        """, (source, destination, date))
    else:
        cursor.execute("""
            SELECT 
                ride.origin, 
                ride.destination, 
                ride.date,
                ride.time, 
                ride.available_seats, 
                ride.via,
                users.firstname, 
                users.lastname, 
                users.contact
            FROM ride
            JOIN users ON ride.ride_giver_id = users.id
            WHERE ride.origin = ? AND ride.destination = ?
        """, (source, destination))

    rides = cursor.fetchall()
    conn.close()

    return render_template('ride_results.html', rides=rides)


@app.route('/logout')
def logout():
    session.clear()  # This logs the user out by clearing session data
    return redirect('/log') # Redirects to login page
    

if __name__ == "__main__":
    app.run(debug=True)
