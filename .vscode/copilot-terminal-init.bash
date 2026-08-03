# Copilot terminal 與 sandbox 內層 Bash 共用的專案暫存目錄初始化。
_copilot_project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
_copilot_tmp_dir="${_copilot_project_root}/tmp"

if ! mkdir -p -- "${_copilot_tmp_dir}"; then
    printf '無法建立專案暫存目錄：%s\n' "${_copilot_tmp_dir}" >&2
    return 1 2>/dev/null || exit 1
fi

export TMPDIR="${_copilot_tmp_dir}"
export CLAUDE_TMPDIR="${_copilot_tmp_dir}"

unset _copilot_project_root _copilot_tmp_dir
