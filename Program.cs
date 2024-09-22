using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Text;

class Start {
    public static void Main(string[] args) {
        Stopwatch watch = new();
        watch.Start();
        Trans(new Param().Args(args));
        watch.Stop();
        TimeSpan elapsed = watch.Elapsed;
        Console.WriteLine($"转换用时: {elapsed.ToString()}");
    }


    private static void Trans(Param param) {
        if (!File.Exists(param.InputFilename)) {
            throw new FileNotFoundException($"{param.InputFilename} 不存在，不能作为输入参数");
        }
        if (File.Exists(param.OutputFilename)) {
            throw new Exception($"{param.OutputFilename} 已存在，不能作为输出文件");
        }
        var code = CodeFactory.Create(param.CI);
        using StreamWriter sw = new(File.Create(param.OutputFilename));
        foreach (var line in File.ReadLines(param.InputFilename)) {
            var newline = code.HandleLine(line.Trim());
            if (newline != null) sw.WriteLine(newline);
        }
    }
}

public interface Code {
    static readonly string[] four_yunmus = ["iong", "uang", "iang"];
    static readonly string[] three_yunmus = ["uan", "ing", "uai", "ong", "eng", "ang", "iao", "ian"];
    static readonly string[] two_yunmus = ["iu", "ia", "ua", "ue", "ve", "uo", "un", "en", "an", "ao", "ai", "ei", "ie", "ui", "ou", "in", "er"];
    static readonly string[] one_yunmus = ["a", "o", "e", "i", "u", "v"];
    static readonly string[] one_shengmus = ["q", "w", "r", "t", "y", "p", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "b", "n", "m"];
    static readonly string[] two_shengmus = ["zh", "ch", "sh"];

    public string? HandleLine(string line);
}

public class CodeFactory() {
    public static Code Create(int ci) => ci switch {
        0 => new NatureCode(),
        _ => throw new Exception("暂不支持该码"),
    };
}

class NatureCode : Code {
    private readonly Dictionary<string, string> FourYunMuMap = new() {
        {"iong", "s"},
        {"uang", "d"},
        {"iang", "d"},
    };
    private readonly Dictionary<string, string> ThreeYunMuMap = new() {
        {"uan", "r"},
        {"ing", "y"},
        {"uai", "y"},
        {"ong", "s"},
        {"eng", "g"},
        {"ang", "h"},
        {"iao", "c"},
        {"ian", "m"},
        {"uer", "uer"},
        {"ver", "ver"},
        {"ier", "ier"},
        {"ien", "ien"},
        {"uen", "uen"},
        {"ven", "ven"},
    };
    private readonly Dictionary<string, string> TwoYunMuMap = new() {
        {"iu", "q"},
        {"ia", "w"},
        {"ua", "w"},
        {"ue", "t"},
        {"ve", "t"},
        {"uo", "o"},
        {"un", "p"},
        {"en", "f"},
        {"an", "j"},
        {"ao", "k"},
        {"ai", "l"},
        {"ei", "z"},
        {"ie", "x"},
        {"ui", "v"},
        {"ou", "b"},
        {"in", "n"},
        {"er", "r"},
    };
    private readonly Dictionary<string, string> TwoShengMuMap = new() {
        {"zh", "v"},
        {"ch", "i"},
        {"sh", "u"},
    };

    private string GetShengmu(string pinyin, ref int i) {
        if (i >= pinyin.Length) {
            return "";
        }
        // 零声母
        var thisone = pinyin.Substring(i, 1);
        if (Code.one_yunmus.Contains(thisone)) {
            return thisone;
        }
        // 双声母
        if (i + 1 < pinyin.Length && TwoShengMuMap.ContainsKey(pinyin.Substring(i, 2))) {
            var shengmu = TwoShengMuMap[pinyin.Substring(i, 2)];
            i += 2;
            return shengmu;
        }
        // 单声母
        i += 1;
        return thisone;
    }
    private string GetYunmu(string pinyin, ref int i) {
        string tmp;
        // 4韵母
        if (i + 3 < pinyin.Length && FourYunMuMap.ContainsKey(pinyin.Substring(i, 4))) {
            tmp = FourYunMuMap[pinyin.Substring(i, 4)];
            i += 4;
            return tmp;
        }
        // 3韵母
        if (i + 2 < pinyin.Length && ThreeYunMuMap.ContainsKey(pinyin.Substring(i, 3))) {
            tmp = ThreeYunMuMap[pinyin.Substring(i, 3)];
            i += 3;
            return tmp;
        }
        // 2韵母
        if (i + 1 < pinyin.Length && TwoYunMuMap.ContainsKey(pinyin.Substring(i, 2))) {
            tmp = TwoYunMuMap[pinyin.Substring(i, 2)];
            i += 2;
            return tmp;
        }
        // 1韵母
        tmp = pinyin.Substring(i, 1);
        i += 1;
        return tmp;
    }

    public string? HandleLine(string line) {
        if (line.StartsWith('#')) {
            return line;
        } else {
            // 查找第一个空白字符所在位置
            int space_index = 0;
            while (space_index < line.Length) {
                if (char.IsWhiteSpace(line[space_index])) {
                    break;
                }
                space_index++;
            }
            if (space_index < 0) return null;
            var pinyin = line[..space_index];
            var after = line[space_index..];
            if (after.Trim().Length == 0) return null;

            StringBuilder sb = new();

            int i = 0;
            while (i < pinyin.Length) {
                string s = "", y = "";
                try {
                    s = GetShengmu(pinyin, ref i);
                    y = GetYunmu(pinyin, ref i);
                    // Console.WriteLine($"声母:{s}, 韵母:{y}");
                    sb.Append(s);
                    sb.Append(y);
                } catch (Exception e) {
                    Console.WriteLine($"执行出错, 当前行: {pinyin}, 当前下标: {i}, 当前声母: {s}, 当前韵母: {y}, 错误: {e}");
                    throw;
                }
            }
            return sb.ToString() + after;
        }
    }
}

public class Param {
    public string InputFilename { get; private set; } = "";

    public string OutputFilename { get; private set; } = "";
    public int CI = 0;

    public Param Args(string[] args) {
        for (int i = 0; i < args.Length; i++) {
            var arg = args[i];
            // Console.WriteLine($"arg={arg}");
            switch (arg) {
                case "-i":
                    if (args.Length < i + 2) {
                        throw new Exception("缺少 -i 参数");
                    }
                    InputFilename = args[i + 1];
                    i++;
                    break;
                case "-o":
                    if (args.Length < i + 2) {
                        throw new Exception("缺少 -o 参数");
                    }
                    OutputFilename = args[i + 1];
                    i++;
                    break;
                case "-ci":
                    if (!int.TryParse(args[i + 1], out CI)) {
                        throw new Exception($"转换 -ci({args[i + 1]}) 参数失败");
                    }
                    i++;
                    break;
                default:
                    break;
            }
        }
        if (InputFilename.Length == 0) {
            throw new Exception("缺少 -i 参数");
        }
        if (OutputFilename.Length == 0) {
            OutputFilename = $"output_{DateTime.Now:yyyyMMddHHmmss}.txt";
        }
        return this;
    }
}