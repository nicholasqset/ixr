package com.qset.academic;

import com.qset.sys.Sys;

/**
 *
 * @author nicholas
 */
public class Academic {

    public String getGrade(Double score, String comCode) {
        String html = "";
        Sys system = new Sys();

        html += system.getOne(comCode+".AAGRADESYS", "GRADE", "(MINPER <= " + score + " AND MAXPER >= " + score + ")");

        return html;
    }

}
