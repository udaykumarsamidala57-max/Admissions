package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.DBUtil;

@WebServlet("/MarksReport")
public class MarksReport extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String classIdRaw = request.getParameter("class_id");
        String examDate = request.getParameter("exam_date");

        if (classIdRaw == null || examDate == null || examDate.trim().isEmpty()) {
            out.println("<p style='color:red;'>Please provide both Class ID and Exam Date.</p>");
            return;
        }

        int classId = Integer.parseInt(classIdRaw);

        try (Connection con = DBUtil.getConnection()) {

            // 1. LOAD EXAMS
            ArrayList<Integer> examIds = new ArrayList<>();
            ArrayList<String> examNames = new ArrayList<>();
            ArrayList<Integer> maxMarksArray = new ArrayList<>();

            String examQuery = "SELECT exam_id, exam_name, max_marks FROM class_exams WHERE class_id=?";
            try (PreparedStatement psExams = con.prepareStatement(examQuery)) {
                psExams.setInt(1, classId);
                try (ResultSet rsExams = psExams.executeQuery()) {
                    while (rsExams.next()) {
                        examIds.add(rsExams.getInt("exam_id"));
                        examNames.add(rsExams.getString("exam_name"));
                        maxMarksArray.add(rsExams.getInt("max_marks"));
                    }
                }
            }

            if (examIds.isEmpty()) {
                out.println("<p style='color:red;'>No exams defined for this class.</p>");
                return;
            }

            // 2. LOAD ALL MARKS INTO MAP
            HashMap<String, Integer> marksMap = new HashMap<>();
            String marksQuery = "SELECT enquiry_id, exam_id, marks_obtained FROM student_exam_marks WHERE exam_date=?";
            try (PreparedStatement psAllMarks = con.prepareStatement(marksQuery)) {
                psAllMarks.setString(1, examDate);
                try (ResultSet rsAllMarks = psAllMarks.executeQuery()) {
                    while (rsAllMarks.next()) {
                        String key = rsAllMarks.getInt("enquiry_id") + "_" + rsAllMarks.getInt("exam_id");
                        marksMap.put(key, rsAllMarks.getInt("marks_obtained"));
                    }
                }
            }

            // 3. GENERATE TABLE HEADER
            out.println("<table class='marksTable'>");
            out.println("<thead>");
            out.println("<tr>");
            out.println("<th>S.No</th><th>Enquiry ID</th><th>App No</th><th>Student Name</th><th>Type</th><th>Segment</th>");
            // Father's Separate Columns
            out.println("<th>Father Name</th><th>Father Occupation</th><th>Father Organization</th><th>Father Mobile</th>");
            // Mother's Separate Columns
            out.println("<th>Mother Name</th><th>Mother Occupation</th><th>Mother Organization</th><th>Mother Mobile</th>");
            // Place and Remarks
            out.println("<th>Place From</th><th>Entrance Remarks</th>");

            for (int i = 0; i < examNames.size(); i++) {
                out.println("<th>" + examNames.get(i) + "<br>(" + maxMarksArray.get(i) + ")</th>");
            }
            out.println("<th>Total</th>");
            out.println("<th>Percentage</th>");
            out.println("</tr>");
            out.println("</thead>");

            // 4. LOAD STUDENTS AND POPULATE ROWS
            String studentQuery = "SELECT ae.enquiry_id, IFNULL(ae.application_no, '') AS application_no, " +
                                 "COALESCE(ae.student_name, ae.entrance_remarks) AS student_name, " +
                                 "ae.entrance_remarks, ae.admission_type, ae.father_name, ae.father_occupation, ae.father_organization,ae.segment, " +
                                 "ae.father_mobile_no, ae.mother_name, ae.mother_occupation, ae.mother_organization, ae.mother_mobile_no, ae.place_from " +
                                 "FROM admission_enquiry ae " +
                                 "JOIN classes c ON TRIM(ae.class_of_admission) = TRIM(c.class_name) " +
                                 "WHERE c.class_id=? AND ae.approved='Approved' AND ae.exam_date=? " +
                                 "ORDER BY ae.enquiry_id";

            out.println("<tbody>");
            try (PreparedStatement psStudents = con.prepareStatement(studentQuery)) {
                psStudents.setInt(1, classId);
                psStudents.setString(2, examDate);

                try (ResultSet rsStudents = psStudents.executeQuery()) {
                    boolean found = false;
                    int sno = 1;

                    while (rsStudents.next()) {
                        found = true;
                        int enqId = rsStudents.getInt("enquiry_id");

                        out.println("<tr>");
                        out.println("<td>" + (sno++) + "</td>");
                        out.println("<td>" + enqId + "</td>");
                        out.println("<td>" + rsStudents.getString("application_no") + "</td>");
                        out.println("<td style='text-align:left'><b>" + rsStudents.getString("student_name") + "</b></td>");
                        out.println("<td>" + rsStudents.getString("admission_type") + "</td>");
                        out.println("<td>" + rsStudents.getString("segment") + "</td>");
                        
                        // Father Columns
                        out.println("<td>" + rsStudents.getString("father_name") + "</td>");
                        out.println("<td>" + rsStudents.getString("father_occupation") + "</td>");
                        out.println("<td>" + rsStudents.getString("father_organization") + "</td>");
                        out.println("<td>" + rsStudents.getString("father_mobile_no") + "</td>");
                        
                        // Mother Columns
                        out.println("<td>" + rsStudents.getString("mother_name") + "</td>");
                        out.println("<td>" + rsStudents.getString("mother_occupation") + "</td>");
                        out.println("<td>" + rsStudents.getString("mother_organization") + "</td>");
                        out.println("<td>" + rsStudents.getString("mother_mobile_no") + "</td>");
                        
                        // Place and Remarks
                        out.println("<td>" + rsStudents.getString("place_from") + "</td>");
                        out.println("<td>" + 
                        	    (rsStudents.getString("entrance_remarks") == null 
                        	        ? "" 
                        	        : rsStudents.getString("entrance_remarks")) 
                        	    + "</td>");

                        int rowTotal = 0;
                        int rowMaxPossible = 0;

                        for (int i = 0; i < examIds.size(); i++) {
                            int examId = examIds.get(i);
                            int maxM = maxMarksArray.get(i);
                            rowMaxPossible += maxM;

                            Integer marks = marksMap.get(enqId + "_" + examId);
                            int mVal = (marks == null) ? 0 : marks;
                            rowTotal += mVal;

                            out.println("<td>" + mVal + "</td>");
                        }
                        
                        double percentage = (rowMaxPossible > 0) ? ((double) rowTotal / rowMaxPossible) * 100 : 0;

                        out.println("<td><input class='totalBox' readonly value='" + rowTotal + "'></td>");
                        out.println("<td><input class='percentBox' readonly value='" + String.format("%.2f", percentage) + "'></td>");
                        out.println("</tr>");
                    }

                    if (!found) {
                        // Colspan updated to 17 (fixed cols) + dynamic exam count
                        out.println("<tr><td colspan='" + (17 + examIds.size()) + "'>No students found.</td></tr>");
                    }
                }
            }
            out.println("</tbody>");
            out.println("</table>");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        }
    }
}