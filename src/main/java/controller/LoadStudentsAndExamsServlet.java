package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.DBUtil;

@WebServlet("/LoadStudentsAndExamsServlet")
public class LoadStudentsAndExamsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        int classId = Integer.parseInt(request.getParameter("class_id"));
        String examDate = request.getParameter("exam_date");

        if (examDate == null || examDate.trim().equals("")) {
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

            // ================= LOAD STUDENTS (DATE FILTERED) =================
            PreparedStatement psStudents = con.prepareStatement(
                "SELECT ae.enquiry_id, ae.student_name " +
                "FROM admission_enquiry ae " +
                "JOIN classes c ON ae.class_of_admission = c.class_name " +
                "WHERE c.class_id=? AND ae.approved='Approved' AND ae.exam_date=?"
            );
            psStudents.setInt(1, classId);
            psStudents.setString(2, examDate);

            ResultSet rsStudents = psStudents.executeQuery();

            boolean found = false;

            // ================= TABLE HEADER =================
            out.println("<table class='marksTable'>");
            out.println("<tr><th>Enquiry</th><th>Name</th>");

            for (int i = 0; i < examNames.size(); i++) {
                out.println("<th>" + examNames.get(i) + "<br>(" + maxMarks.get(i) + ")</th>");
            }
            out.println("<th>Total</th></tr>");

            // ================= TABLE BODY =================
            while (rsStudents.next()) {
                found = true;

                int enquiryId = rsStudents.getInt("enquiry_id");
                String studentName = rsStudents.getString("student_name");

                out.println("<tr>");
                out.println("<td>" + enquiryId + "</td>");
                out.println("<td>" + studentName + "</td>");

                int total = 0;

                for (int i = 0; i < examIds.size(); i++) {

                    PreparedStatement psMark = con.prepareStatement(
                        "SELECT marks_obtained FROM student_exam_marks " +
                        "WHERE enquiry_id=? AND exam_id=? AND exam_date=?"
                    );
                    psMark.setInt(1, enquiryId);
                    psMark.setInt(2, examIds.get(i));
                    psMark.setString(3, examDate);

                    ResultSet rsMark = psMark.executeQuery();

                    int marks = 0;
                    if (rsMark.next()) {
                        marks = rsMark.getInt("marks_obtained");
                    }

                    rsMark.close();
                    psMark.close();

                    total += marks;

                    out.println("<td>");
                    out.println("<input type='number' class='markInput' min='0' max='" + maxMarks.get(i) + "' " +
                        "name='marks_" + enquiryId + "_" + examIds.get(i) + "' " +
                        "value='" + marks + "' oninput='calculateRowTotal(this)'>");
                    out.println("</td>");
                }

                out.println("<td><input class='totalBox' readonly value='" + total + "'></td>");
                out.println("</tr>");
            }

            out.println("</table>");

            rsStudents.close();
            psStudents.close();

            if (found) {
                out.println("<br><button type='submit' class='saveBtn'>💾 Save Marks</button>");
            } else {
                out.println("<p style='color:red;font-weight:bold;'>No students found for selected exam date.</p>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>Error loading data.</p>");
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
