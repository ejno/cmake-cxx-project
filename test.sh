set -euC


cd "$(dirname "${0}")"


readonly config=Release
readonly project_name=project
readonly source_path="${PWD}/../${project_name}"
readonly build_path="${PWD}/build/${config}"
readonly install_path="${build_path}/install"


if ! test -e "${build_path}"; then
    readonly upper_project_name="$(echo "${project_name}" |
        tr '[:lower:]' '[:upper:]')"

    cmake -G Ninja -S "${source_path}" -B "${build_path}" \
        "-DCMAKE_BUILD_TYPE=${config}" \
        "-DCMAKE_INSTALL_PREFIX=${install_path}" \
        "-DCMAKE_CXX_COMPILER=$(which g++)" \
        "-D${upper_project_name}_ENABLE_IPO=FALSE" \
        -DBUILD_SHARED_LIBS=TRUE \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=TRUE
fi


cmake --build "${build_path}" --config "${config}"


cd "${build_path}"
ctest --build-config "${config}" --schedule-random
cd -
