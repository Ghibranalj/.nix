{ config, lib, pkgs, ... }:

let
  inherit (lib) listToAttrs map foldl' attrNames attrValues head;

  skills = [{
    name = "suggest-commit-message";
    description =
      "Suggest git commit messages based on staged changes, following the repository's commit style";
    markdown = ''
      # Commit Message Suggester

      Suggest git commit messages based on staged changes, following the repository's commit style.

      ## Procedure

      1. Run `bash ~/.claude/skills/suggest-commit-message/scripts/collect.sh` to gather all git info
      2. **Learn this project's commit style** from recent history:
         - Does it use conventional commits (`feat:`, `fix:`)?
         - Does it use scopes like `(area):`?
         - Is it verbose or concise?
         - Any special patterns?
      5. Suggest 1-3 commit message options **following this project's style**
      6. Present options concisely, user can pick one
    '';
    script = [{
      "collect.sh" = ''
        #!/usr/bin/env bash
        echo "=== STAGED STAT ==="
        git diff --staged --stat
        echo ""
        echo "=== STAGED DIFF ==="
        git diff --staged
        echo ""
        echo "=== RECENT COMMITS ==="
        git log -20 --oneline
      '';
    }];
    extraFiles = {
      # "template.css" = "...";
    };
  }];

  # Convert list of attrs to single attrs (for script list)
  mergeAttrsList = list: foldl' (acc: item: acc // item) { } list;

  buildSkillFiles = skill:
    let
      skillDir = ".claude/skills/${skill.name}";
      baseFiles = {
        "${skillDir}/SKILL.md" = {
          text = ''
            ---
            name: ${skill.name}
            description: ${skill.description}
            ---

            ${skill.markdown}
          '';
        };
      };
      scriptFiles = listToAttrs (map (item:
        let
          filename = head (attrNames item);
          content = head (attrValues item);
        in {
          name = "${skillDir}/scripts/${filename}";
          value = {
            text = content;
            executable = true;
          };
        }) skill.script);
      extraFileAttrs = listToAttrs (map (relPath: {
        name = "${skillDir}/${relPath}";
        value = { text = skill.extraFiles.${relPath}; };
      }) (attrNames skill.extraFiles));
    in baseFiles // scriptFiles // extraFileAttrs;

  allSkillFiles = foldl' (acc: skill: acc // buildSkillFiles skill) { } skills;

in {
  options = with lib; { ai.enable = mkEnableOption "enable AI helper tools"; };

  config = lib.mkIf config.ai.enable {
    home.file = allSkillFiles;
  };
}
