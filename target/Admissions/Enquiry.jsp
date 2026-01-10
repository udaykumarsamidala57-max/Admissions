<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Admission Enquiry Form</title>

<style>
* { box-sizing: border-box; }

body {
    font-family: "Segoe UI", Arial, sans-serif;
    background: linear-gradient(135deg, #dbeafe, #f0f9ff);
    margin: 0;
    padding: 0;
}

.form-box {
    max-width: 700px;
    width: 95%;
    margin: 20px auto;
    background: #ffffff;
    padding: 18px;
    border-radius: 14px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.15);
}

h2 {
    text-align: center;
    color: #1e40af;
    margin-bottom: 18px;
}

.section-card {
    margin-top: 18px;
    padding: 16px;
    border-radius: 12px;
    background: #f8fafc;
    border: 1px solid #e2e8f0;
}

.section-title {
    font-size: 15px;
    font-weight: bold;
    color: #1e40af;
    margin-bottom: 10px;
    border-left: 5px solid #3b82f6;
    padding-left: 10px;
}

/* ✅ SINGLE COLUMN */
.form-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 12px;
}

.form-field {
    display: flex;
    flex-direction: column;
}

label {
    font-weight: 600;
    font-size: 13px;
    color: #1f2937;
    margin-bottom: 4px;
}

input, select {
    height: 42px;
    padding: 0 12px;
    border-radius: 8px;
    border: 1px solid #cbd5e1;
    font-size: 15px;
    transition: 0.3s;
    background: white;
    width: 100%;
}

input:focus, select:focus {
    border-color: #3b82f6;
    box-shadow: 0 0 0 2px rgba(59,130,246,0.15);
    outline: none;
}

.submit-box {
    text-align: center;
    margin-top: 22px;
}

button {
    padding: 12px 36px;
    font-size: 16px;
    background: linear-gradient(135deg, #2563eb, #1e40af);
    color: white;
    border: none;
    border-radius: 30px;
    cursor: pointer;
    box-shadow: 0 6px 15px rgba(37,99,235,0.4);
    transition: 0.3s;
}

button:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(37,99,235,0.5);
}

.error-msg {
    color: red;
    font-size: 14px;
}
</style>

</head>
<body>

<div class="form-box">
<h2>📘 Admission Enquiry Form</h2>

<form action="SaveEnquiryServlet" method="post" onsubmit="return validateBeforeSubmit();">

<!-- Student Details -->
<div class="section-card">
<div class="section-title">Student Details</div>
<div class="form-grid">

<div class="form-field">
<label>Student Name *</label>
<input type="text" name="student_name" required>
</div>

<div class="form-field">
<label>Gender</label>
<select name="gender">
<option value="">-- Select Gender --</option>
<option>Male</option>
<option>Female</option>
</select>
</div>

<div class="form-field">
<label>Date of Birth</label>
<input type="date" name="date_of_birth" id="dob" oninput="calculateAge()">
</div>

<div class="form-field">
<label>Age (Years, Months, Days)</label>
<input type="text" name="age" id="age" readonly>
</div>

<div class="form-field">
<label>Class of Admission</label>
<select name="class_of_admission">
<option value="">-- Select Class --</option>
<option>LKG</option><option>UKG</option>
<option>Class 1</option><option>Class 2</option><option>Class 3</option>
<option>Class 4</option><option>Class 5</option><option>Class 6</option>
<option>Class 7</option><option>Class 8</option>
</select>
</div>

<div class="form-field">
<label>Admission Type</label>
<select name="admission_type">
<option value="">-- Select Admission Type --</option>
<option>Dayscholar</option>
<option>Residential</option>
<option>Semi Residential</option>
</select>
</div>

</div>
</div>

<!-- Father Details -->
<div class="section-card">
<div class="section-title">Father Details</div>
<div class="form-grid">

<div class="form-field"><label>Father Name</label><input type="text" name="father_name"></div>
<div class="form-field"><label>Occupation</label><input type="text" name="father_occupation"></div>
<div class="form-field"><label>Organization</label><input type="text" name="father_organization"></div>

<div class="form-field">
<label>Mobile Number</label>
<input type="text" name="father_mobile_no" id="father_mobile" maxlength="10" onkeyup="checkMobile(this.value)">
<div id="mobileMsg" class="error-msg"></div>
</div>

</div>
</div>

<!-- Mother Details -->
<div class="section-card">
<div class="section-title">Mother Details</div>
<div class="form-grid">

<div class="form-field"><label>Mother Name</label><input type="text" name="mother_name"></div>
<div class="form-field"><label>Occupation</label><input type="text" name="mother_occupation"></div>
<div class="form-field"><label>Organization</label><input type="text" name="mother_organization"></div>

<div class="form-field">
<label>Mobile Number</label>
<input type="text" name="mother_mobile_no" id="mother_mobile" maxlength="10" onkeyup="checkMobile(this.value)">
</div>

</div>
</div>

<!-- Other Details -->
<div class="section-card">
<div class="section-title">Other Details</div>
<div class="form-grid">

<div class="form-field">
<label>Segment</label>
<select name="segment">
<option value="">-- Select Segment --</option>
<option>General</option>
<option>SMIORE</option>
<option>SVPS</option>
<option>SVPSGEN</option>
<option>RTE</option>
</select>
</div>

<div class="form-field">
<label>Place From</label>
<input type="text" name="place_from">
</div>

</div>
</div>

<div class="submit-box" id="submitBox">
<button type="submit" id="submitBtn">Submit Enquiry</button>
</div>

</form>
</div>

<script>
let mobileExists = false;

// ✅ Age calculation
function calculateAge() {
    let dobValue = document.getElementById("dob").value;
    if (!dobValue) {
        document.getElementById("age").value = "";
        return;
    }

    let dob = new Date(dobValue);
    let today = new Date();

    let years = today.getFullYear() - dob.getFullYear();
    let months = today.getMonth() - dob.getMonth();
    let days = today.getDate() - dob.getDate();

    if (days < 0) {
        months--;
        let prevMonth = new Date(today.getFullYear(), today.getMonth(), 0);
        days += prevMonth.getDate();
    }

    if (months < 0) {
        years--;
        months += 12;
    }

    document.getElementById("age").value = years + " Years " + months + " Months " + days + " Days";
}

// ✅ AJAX Mobile Check
function checkMobile(mobile) {
    if (mobile.length != 10) {
        resetSubmit();
        return;
    }

    let xhr = new XMLHttpRequest();
    xhr.open("GET", "SaveEnquiryServlet?mobile=" + mobile, true);

    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4 && xhr.status == 200) {
            let response = xhr.responseText.trim();

            if (response === "EXISTS") {
                alert("⚠ This mobile number is already submitted!");
                document.getElementById("mobileMsg").innerHTML = "This mobile number already exists!";
                document.getElementById("submitBox").style.display = "none";
                mobileExists = true;
            } else {
                document.getElementById("mobileMsg").innerHTML = "";
                document.getElementById("submitBox").style.display = "block";
                mobileExists = false;
            }
        }
    };
    xhr.send();
}

function resetSubmit() {
    document.getElementById("submitBox").style.display = "block";
    document.getElementById("mobileMsg").innerHTML = "";
    mobileExists = false;
}

function validateBeforeSubmit() {
    if (mobileExists) {
        alert("This mobile number already exists!");
        return false;
    }
    return true;
}
</script>

</body>
</html>
