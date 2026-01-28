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

@WebServlet("/LoadStudentsAndExamsServlet")
public class LoadStudentsAndExamsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        int classId = Integer.parseInt(request.getParameter("class_id"));
        String examDate = request.getParameter("exam_date");

        if (examDate == null || examDate.trim().isEmpty()) {
            out.println("<p style='color:red;'>Please select exam date.</p>");
            return;
        }

        Connection con = null;

        try {
            con = DBUtil.getConnection();

            // ================= LOAD EXAMS =================
            PreparedStatement psExams = con.prepareStatement(
                "SELECT exam_id, exam_name, max_marks FROM class_exams WHERE class_id=?"
            );
            psExams.setInt(1, classId);
            ResultSet rsExams = psExams.executeQuery();

            ArrayList<Integer> examIds = new ArrayList<>();
            ArrayList<String> examNames = new ArrayList<>();
            ArrayList<Integer> maxMarks = new ArrayList<>();

            while (rsExams.next()) {
                examIds.add(rsExams.getInt("exam_id"));
                examNames.add(rsExams.getString("exam_name"));
                maxMarks.add(rsExams.getInt("max_marks"));
            }

            rsExams.close();
            psExams.close();

            if (examIds.isEmpty()) {
                out.println("<p style='color:red;'>No exams defined for this class.</p>");
                return;
            }

            // ================= LOAD STUDENTS =================
            PreparedStatement psStudents = con.prepareStatement(
                "SELECT " +
                " ae.enquiry_id, " +
                " IFNULL(ae.application_no, '') AS application_no, " +
                " COALESCE(ae.student_name, ae.entrance_remarks) AS student_name, " +
                " ae.entrance_remarks " +
                "FROM admission_enquiry ae " +
                "JOIN classes c ON TRIM(ae.class_of_admission) = TRIM(c.class_name) " +
                "WHERE c.class_id=? AND ae.approved='Approved' AND ae.exam_date=? " +
                "ORDER BY ae.enquiry_id"
            );

            psStudents.setInt(1, classId);
            psStudents.setString(2, examDate);

            ResultSet rsStudents = psStudents.executeQuery();

            // ================= LOAD ALL MARKS =================
            PreparedStatement psAllMarks = con.prepareStatement(
                "SELECT enquiry_id, exam_id, marks_obtained FROM student_exam_marks WHERE exam_date=?"
            );
            psAllMarks.setString(1, examDate);

            ResultSet rsAllMarks = psAllMarks.executeQuery();

            HashMap<String, Integer> marksMap = new HashMap<>();

            while (rsAllMarks.next()) {
                String key = rsAllMarks.getInt("enquiry_id") + "_" + rsAllMarks.getInt("exam_id");
                marksMap.put(key, rsAllMarks.getInt("marks_obtained"));
            }

            rsAllMarks.close();
            psAllMarks.close();

            // ================= TABLE HEADER =================
            out.println("<table class='marksTable'>");
            out.println("<tr>");
            out.println("<th>S.No</th>");
            out.println("<th>Enquiry ID</th>");
            out.println("<th>Application No</th>");
            out.println("<th>Student Name</th>");
            out.println("<th>Entrance Remarks</th>");

            for (int i = 0; i < examNames.size(); i++) {
                out.println("<th>" + examNames.get(i) + "<br>(" + maxMarks.get(i) + ")</th>");
            }

            out.println("<th>Total</th>");
            out.println("</tr>");

            // ================= TABLE BODY =================
            boolean found = false;
            int sno = 1;

            while (rsStudents.next()) {
                found = true;

                int enquiryId = rsStudents.getInt("enquiry_id");
                String appNo = rsStudents.getString("application_no");
                String studentName = rsStudents.getString("student_name");
                String remarks = rsStudents.getString("entrance_remarks");

                out.println("<tr>");
                out.println("<td>" + (sno++) + "</td>");
                out.println("<td><b>" + enquiryId + "</b></td>");
                out.println("<td><b>" + (appNo == null ? "" : appNo) + "</b></td>");
                out.println("<td style='text-align:left'>" + (studentName == null ? "" : studentName) + "</td>");
                out.println("<td><input class='remarksBox' name='remarks_" + enquiryId + "' value='" + (remarks == null ? "" : remarks) + "'></td>");

                int total = 0;

                for (int i = 0; i < examIds.size(); i++) {
                    int examId = examIds.get(i);

                    Integer marksObj = marksMap.get(enquiryId + "_" + examId);
                    int marks = (marksObj == null) ? 0 : marksObj;

                    total += marks;

                    out.println("<td>");
                    out.println("<input type='number' class='markInput' min='0' max='" + maxMarks.get(i) + "' " +
                        "name='marks_" + enquiryId + "_" + examId + "' " +
                        "value='" + marks + "'>");
                    out.println("</td>");
                }

                out.println("<td><input class='totalBox' readonly value='" + total + "'></td>");
                out.println("</tr>");
            }

            out.println("</table>");

            rsStudents.close();
            psStudents.close();

            if (!found) {
                out.println("<p style='color:red;font-weight:bold;'>No students found for selected exam date.</p>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>Error loading data.</p>");
        } finally {
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
