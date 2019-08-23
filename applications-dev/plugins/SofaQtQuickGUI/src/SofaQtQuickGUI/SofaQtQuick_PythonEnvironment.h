#pragma once

#include "config.h"

#include <string>
#include <map>

namespace sofaqtquick {
class SOFA_SOFAQTQUICKGUI_API PythonEnvironment
{
public:
    /// Retrieves the global docstring present in a python script
    static std::string getPythonScriptDocstring(const std::string& moduleDir, const std::string& moduleName);

    /// Retrieves a map of all callable functions present in a python script.
    /// The map contains as keys the name of the callable functions,
    /// and as values their type (functoin, class, prefab, controller...) and docstring
    static std::map<std::string, std::pair<std::string, std::string>> getPythonScriptContent(const std::string& moduleDir, const std::string& moduleName);

};

}  // namespace sofaqtquick
