package bean.academic;

import bean.sys.Sys;

/**
 *
 * @author nicholas
 */
public class Academic {

    public String getGrade(Double score) {
        String html = "";
        Sys system = new Sys();

        html += system.getOne("AAGRADESYS", "GRADE", "(MINPER <= " + score + " AND MAXPER >= " + score + ")");

        return html;
    }

}
