package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Enumeration;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.DBUtil;

@WebServlet("/SaveMarksServlet")
public class SaveMarksServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

        String examDate = request.getParameter("exam_date_hidden");

        Connection con = null;
        PreparedStatement psCheck = null;
        PreparedStatement psInsert = null;
        PreparedStatement psUpdate = null;

        try {
            con = DBUtil.getConnection();
            con.setAutoCommit(false);

            // Check existing
            psCheck = con.prepareStatement(
                "SELECT marks_obtained FROM student_exam_marks WHERE enquiry_id=? AND exam_id=?"
            );

            // Insert new
            psInsert = con.prepareStatement(
                "INSERT INTO student_exam_marks(enquiry_id, exam_id, marks_obtained, exam_date) VALUES(?,?,?,?)"
            );

            // Update existing
            psUpdate = con.prepareStatement(
                "UPDATE student_exam_marks SET marks_obtained=?, exam_date=? WHERE enquiry_id=? AND exam_id=?"
            );

            Enumeration<String> params = request.getParameterNames();

            while (params.hasMoreElements()) {
                String param = params.nextElement();

                if (param.startsWith("marks_")) {
                    String[] parts = param.split("_");

                    int enquiryId = Integer.parseInt(parts[1]);
                    int examId = Integer.parseInt(parts[2]);
                    int newMarks = Integer.parseInt(request.getParameter(param));

                    // Check existing marks
                    psCheck.setInt(1, enquiryId);
                    psCheck.setInt(2, examId);
                    ResultSet rs = psCheck.executeQuery();

                    if (rs.next()) {
                        int oldMarks = rs.getInt("marks_obtained");

                        // Update ONLY if changed
                        if (oldMarks != newMarks) {
                            psUpdate.setInt(1, newMarks);
                            psUpdate.setString(2, examDate);
                            psUpdate.setInt(3, enquiryId);
                            psUpdate.setInt(4, examId);
                            psUpdate.addBatch();
                        }
                    } else {
                        // Insert new
                        psInsert.setInt(1, enquiryId);
                        psInsert.setInt(2, examId);
                        psInsert.setInt(3, newMarks);
                        psInsert.setString(4, examDate);
                        psInsert.addBatch();
                    }
                }
            }

            psInsert.executeBatch();
            psUpdate.executeBatch();
            con.commit();

            response.sendRedirect("enter_marks.jsp?msg=success");

        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect("enter_marks.jsp?msg=error");

        } finally {
            try { if (psCheck != null) psCheck.close(); } catch (Exception e) {}
            try { if (psInsert != null) psInsert.close(); } catch (Exception e) {}
            try { if (psUpdate != null) psUpdate.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
