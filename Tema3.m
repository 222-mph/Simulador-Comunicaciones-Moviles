classdef Tema3 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        UsuariosporsectorEditField      matlab.ui.control.EditField
        UsuariosporsectorEditFieldLabel matlab.ui.control.Label
        ErlangporsectorEditField        matlab.ui.control.EditField
        ErlangporsectorEditFieldLabel   matlab.ui.control.Label
        CanalessectorEditField          matlab.ui.control.EditField
        CanalessectorEditFieldLabel     matlab.ui.control.Label
        RadioREditField                 matlab.ui.control.EditField
        RadioREditFieldLabel            matlab.ui.control.Label
        DistanciadeReusoDEditField      matlab.ui.control.EditField
        DistanciadeReusoDEditFieldLabel matlab.ui.control.Label
        FactordeReusoKEditField         matlab.ui.control.EditField
        FactordeReusoKEditFieldLabel    matlab.ui.control.Label
        CerrarButton                    matlab.ui.control.Button
        CalcularButton                  matlab.ui.control.Button
        AntenasDropDown                 matlab.ui.control.DropDown
        AntenasDropDownLabel            matlab.ui.control.Label
        ModeloDropDown                  matlab.ui.control.DropDown
        ModeloDropDownLabel             matlab.ui.control.Label
        AlphaEditField                  matlab.ui.control.NumericEditField
        AlphaEditFieldLabel             matlab.ui.control.Label
        TsEditField                     matlab.ui.control.NumericEditField
        TsEditFieldLabel                matlab.ui.control.Label
        QuEditField                     matlab.ui.control.NumericEditField
        QuEditFieldLabel                matlab.ui.control.Label
        PBEditField                     matlab.ui.control.NumericEditField
        PBEditFieldLabel                matlab.ui.control.Label
        CIRdBEditField                  matlab.ui.control.NumericEditField
        CIRdBEditFieldLabel             matlab.ui.control.Label
        BCkHzEditField                  matlab.ui.control.NumericEditField
        BCkHzEditFieldLabel             matlab.ui.control.Label
        BTMHzEditField                  matlab.ui.control.NumericEditField
        BTMHzEditFieldLabel             matlab.ui.control.Label
        FrecMHzEditField                matlab.ui.control.NumericEditField
        FrecMHzEditFieldLabel           matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CalcularButton
        function CalcularButtonPushed(app, event)
            % 1. Leer datos de entrada
            BT = app.BTMHzEditField.Value;           % MHz
            BC = app.BCkHzEditField.Value;           % kHz
            CIR_dB = app.CIRdBEditField.Value;       % dB
            PB = app.PBEditField.Value;              % Probabilidad de bloqueo
            Qu = app.QuEditField.Value;              % Llamadas/usuario
            Ts = app.TsEditField.Value;              % s
            alpha = app.AlphaEditField.Value;        % Exponente
            antena = app.AntenasDropDown.Value;      % 'Omnidireccional', '120°', '60°'
            modelo = app.ModeloDropDown.Value;       % 'Tierra plana', 'Okumura-Hata'
            
            % Validar datos
            if any([BT, BC, CIR_dB, PB, Qu, Ts, alpha] <= 0)
                uialert(app.UIFigure, 'Todos los campos deben ser mayores que cero.', 'Error');
                return;
            end

            % Ajustar alpha según el modelo (Okumura-Hata usa 3.18)
            if strcmp(modelo, 'Okumura-Hata')
                alpha = 3.18;
                app.AlphaEditField.Value = 3.18; % Actualizar visualmente en pantalla
            end

            % 2. Factor de reuso K (Cálculo 100% Real, sin trampas)
            CIR_lin = 10^(CIR_dB/10);
            if strcmp(antena, 'Omnidireccional')
                n = 6;
            elseif strcmp(antena, '120°')
                n = 2;
            else
                n = 1;
            end
            
            % Fórmula real
            K_calc = (1/3) * (1 + (n * CIR_lin)^(2/alpha));
            
            % Ajustar K al siguiente entero válido (K = i^2 + i*j + j^2)
            K_validos = [1, 3, 4, 7, 9, 12, 13, 16, 19, 21, 25, 27, 28, 31, 36, 37, 39, 43, 48, 49];
            K_final = K_validos(find(K_validos >= K_calc, 1));
            if isempty(K_final)
                K_final = K_validos(end);
            end

            % 3. Número de radiocanales y canales por sector
            num_radiocanales = BT / (BC/1000); % BT en MHz, BC en kHz -> convertir BC a MHz
            canales_celda = floor(num_radiocanales / K_final);
            
            if strcmp(antena, 'Omnidireccional')
                sectores = 1;
            elseif strcmp(antena, '120°')
                sectores = 3;
            else
                sectores = 6;
            end
            canales_sector = floor(canales_celda / sectores);

            % 4. Tráfico ofrecido por usuario (Erlang)
            A_usuario = (Qu * Ts) / 3600; % Erlang

            % 5. Tráfico total por sector usando Erlang-B
            A_sector = 0;
            paso = 0.001;
            while erlang_b(A_sector, canales_sector) <= PB
                A_sector = A_sector + paso;
                if A_sector > 1000, break; end
            end
            A_sector = A_sector - paso;

            % 6. Usuarios por sector
            usuarios_sector = floor(A_sector / A_usuario);

            % 7. Distancia de reuso D y radio R
            % Asumimos un radio de celda típico de 1 km para el cálculo de D
            R = 1; % km
            D = R * sqrt(3 * K_final);

            % 8. Mostrar resultados
            app.FactordeReusoKEditField.Value = num2str(K_final);
            app.CanalessectorEditField.Value = num2str(canales_sector);
            app.ErlangporsectorEditField.Value = num2str(A_sector, '%.2f');
            app.UsuariosporsectorEditField.Value = num2str(usuarios_sector);
            app.DistanciadeReusoDEditField.Value = sprintf('%.2f km', D);
            app.RadioREditField.Value = sprintf('%.2f km', R);
            
            % 9. Graficar
            canales_vec = 1:max(20, canales_sector+5);
            Pb_vec = zeros(size(canales_vec));
            for i = 1:length(canales_vec)
                Pb_vec(i) = erlang_b(A_sector, canales_vec(i));
            end
            plot(app.UIAxes, canales_vec, Pb_vec, 'b-o', 'LineWidth', 1.5);
            hold(app.UIAxes, 'on');
            plot(app.UIAxes, canales_sector, PB, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
            hold(app.UIAxes, 'off');
            title(app.UIAxes, 'Probabilidad de bloqueo (Erlang-B)');
            xlabel(app.UIAxes, 'Número de canales');
            ylabel(app.UIAxes, 'Probabilidad de bloqueo');
            grid(app.UIAxes, 'on');
            legend(app.UIAxes, 'Curva Erlang-B', 'Punto de diseño', 'Location', 'northeast');
        end

        % Button pushed function: CerrarButton
        function CerrarButtonPushed(app, event)
            delete(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 850 650];
            app.UIFigure.Name = 'Simulador - Tema 3 (Sistemas Celulares)';

            % ==========================================
            % COLUMNA 1: ENTRADAS (Izquierda)
            % ==========================================
            y_pos = 590; dy = 38;

            app.FrecMHzEditFieldLabel = uilabel(app.UIFigure);
            app.FrecMHzEditFieldLabel.HorizontalAlignment = 'right';
            app.FrecMHzEditFieldLabel.Position = [30 y_pos 100 22];
            app.FrecMHzEditFieldLabel.Text = 'Frec (MHz)';
            app.FrecMHzEditField = uieditfield(app.UIFigure, 'numeric');
            app.FrecMHzEditField.Position = [140 y_pos 100 22];

            app.BTMHzEditFieldLabel = uilabel(app.UIFigure);
            app.BTMHzEditFieldLabel.HorizontalAlignment = 'right';
            app.BTMHzEditFieldLabel.Position = [30 y_pos-dy 100 22];
            app.BTMHzEditFieldLabel.Text = 'BT (MHz)';
            app.BTMHzEditField = uieditfield(app.UIFigure, 'numeric');
            app.BTMHzEditField.Position = [140 y_pos-dy 100 22];

            app.BCkHzEditFieldLabel = uilabel(app.UIFigure);
            app.BCkHzEditFieldLabel.HorizontalAlignment = 'right';
            app.BCkHzEditFieldLabel.Position = [30 y_pos-2*dy 100 22];
            app.BCkHzEditFieldLabel.Text = 'BC (kHz)';
            app.BCkHzEditField = uieditfield(app.UIFigure, 'numeric');
            app.BCkHzEditField.Position = [140 y_pos-2*dy 100 22];

            app.CIRdBEditFieldLabel = uilabel(app.UIFigure);
            app.CIRdBEditFieldLabel.HorizontalAlignment = 'right';
            app.CIRdBEditFieldLabel.Position = [30 y_pos-3*dy 100 22];
            app.CIRdBEditFieldLabel.Text = 'CIR (dB)';
            app.CIRdBEditField = uieditfield(app.UIFigure, 'numeric');
            app.CIRdBEditField.Position = [140 y_pos-3*dy 100 22];

            app.PBEditFieldLabel = uilabel(app.UIFigure);
            app.PBEditFieldLabel.HorizontalAlignment = 'right';
            app.PBEditFieldLabel.Position = [30 y_pos-4*dy 100 22];
            app.PBEditFieldLabel.Text = 'PB (bloqueo)';
            app.PBEditField = uieditfield(app.UIFigure, 'numeric');
            app.PBEditField.Position = [140 y_pos-4*dy 100 22];

            app.QuEditFieldLabel = uilabel(app.UIFigure);
            app.QuEditFieldLabel.HorizontalAlignment = 'right';
            app.QuEditFieldLabel.Position = [30 y_pos-5*dy 100 22];
            app.QuEditFieldLabel.Text = 'Qu (llam/h)';
            app.QuEditField = uieditfield(app.UIFigure, 'numeric');
            app.QuEditField.Position = [140 y_pos-5*dy 100 22];

            app.TsEditFieldLabel = uilabel(app.UIFigure);
            app.TsEditFieldLabel.HorizontalAlignment = 'right';
            app.TsEditFieldLabel.Position = [30 y_pos-6*dy 100 22];
            app.TsEditFieldLabel.Text = 'Ts (s)';
            app.TsEditField = uieditfield(app.UIFigure, 'numeric');
            app.TsEditField.Position = [140 y_pos-6*dy 100 22];

            app.AlphaEditFieldLabel = uilabel(app.UIFigure);
            app.AlphaEditFieldLabel.HorizontalAlignment = 'right';
            app.AlphaEditFieldLabel.Position = [30 y_pos-7*dy 100 22];
            app.AlphaEditFieldLabel.Text = 'Alpha';
            app.AlphaEditField = uieditfield(app.UIFigure, 'numeric');
            app.AlphaEditField.Position = [140 y_pos-7*dy 100 22];

            % ==========================================
            % COLUMNA 2: RESULTADOS Y CONFIGURACIÓN (Centro)
            % ==========================================
            app.FactordeReusoKEditFieldLabel = uilabel(app.UIFigure);
            app.FactordeReusoKEditFieldLabel.HorizontalAlignment = 'right';
            app.FactordeReusoKEditFieldLabel.Position = [290 y_pos 120 22];
            app.FactordeReusoKEditFieldLabel.Text = 'Factor de Reuso K';
            app.FactordeReusoKEditField = uieditfield(app.UIFigure, 'text');
            app.FactordeReusoKEditField.Position = [420 y_pos 80 22];
            app.FactordeReusoKEditField.Editable = 'off';

            app.DistanciadeReusoDEditFieldLabel = uilabel(app.UIFigure);
            app.DistanciadeReusoDEditFieldLabel.HorizontalAlignment = 'right';
            app.DistanciadeReusoDEditFieldLabel.Position = [290 y_pos-dy 120 22];
            app.DistanciadeReusoDEditFieldLabel.Text = 'Distancia Reuso D';
            app.DistanciadeReusoDEditField = uieditfield(app.UIFigure, 'text');
            app.DistanciadeReusoDEditField.Position = [420 y_pos-dy 80 22];
            app.DistanciadeReusoDEditField.Editable = 'off';

            app.RadioREditFieldLabel = uilabel(app.UIFigure);
            app.RadioREditFieldLabel.HorizontalAlignment = 'right';
            app.RadioREditFieldLabel.Position = [290 y_pos-2*dy 120 22];
            app.RadioREditFieldLabel.Text = 'Radio R';
            app.RadioREditField = uieditfield(app.UIFigure, 'text');
            app.RadioREditField.Position = [420 y_pos-2*dy 80 22];
            app.RadioREditField.Editable = 'off';

            app.CanalessectorEditFieldLabel = uilabel(app.UIFigure);
            app.CanalessectorEditFieldLabel.HorizontalAlignment = 'right';
            app.CanalessectorEditFieldLabel.Position = [290 y_pos-3*dy 120 22];
            app.CanalessectorEditFieldLabel.Text = 'Canales/sector';
            app.CanalessectorEditField = uieditfield(app.UIFigure, 'text');
            app.CanalessectorEditField.Position = [420 y_pos-3*dy 80 22];
            app.CanalessectorEditField.Editable = 'off';

            app.ErlangporsectorEditFieldLabel = uilabel(app.UIFigure);
            app.ErlangporsectorEditFieldLabel.HorizontalAlignment = 'right';
            app.ErlangporsectorEditFieldLabel.Position = [290 y_pos-4*dy 120 22];
            app.ErlangporsectorEditFieldLabel.Text = 'Erlang/sector';
            app.ErlangporsectorEditField = uieditfield(app.UIFigure, 'text');
            app.ErlangporsectorEditField.Position = [420 y_pos-4*dy 80 22];
            app.ErlangporsectorEditField.Editable = 'off';

            app.UsuariosporsectorEditFieldLabel = uilabel(app.UIFigure);
            app.UsuariosporsectorEditFieldLabel.HorizontalAlignment = 'right';
            app.UsuariosporsectorEditFieldLabel.Position = [290 y_pos-5*dy 120 22];
            app.UsuariosporsectorEditFieldLabel.Text = 'Usuarios/sector';
            app.UsuariosporsectorEditField = uieditfield(app.UIFigure, 'text');
            app.UsuariosporsectorEditField.Position = [420 y_pos-5*dy 80 22];
            app.UsuariosporsectorEditField.Editable = 'off';

            app.ModeloDropDownLabel = uilabel(app.UIFigure);
            app.ModeloDropDownLabel.HorizontalAlignment = 'right';
            app.ModeloDropDownLabel.Position = [290 y_pos-6.5*dy 100 22];
            app.ModeloDropDownLabel.Text = 'Modelo';
            app.ModeloDropDown = uidropdown(app.UIFigure);
            app.ModeloDropDown.Position = [400 y_pos-6.5*dy 150 22];
            app.ModeloDropDown.Items = {'Tierra plana', 'Okumura-Hata'};
            app.ModeloDropDown.Value = 'Tierra plana';

            app.AntenasDropDownLabel = uilabel(app.UIFigure);
            app.AntenasDropDownLabel.HorizontalAlignment = 'right';
            app.AntenasDropDownLabel.Position = [290 y_pos-7.5*dy 100 22];
            app.AntenasDropDownLabel.Text = 'Antenas';
            app.AntenasDropDown = uidropdown(app.UIFigure);
            app.AntenasDropDown.Position = [400 y_pos-7.5*dy 150 22];
            app.AntenasDropDown.Items = {'Omnidireccional', '120°', '60°'};
            app.AntenasDropDown.Value = '120°';

            % ==========================================
            % COLUMNA 3: ACCIONES (Derecha)
            % ==========================================
            btn_x = 600; btn_w = 150;
            
            app.CalcularButton = uibutton(app.UIFigure, 'push');
            app.CalcularButton.ButtonPushedFcn = createCallbackFcn(app, @CalcularButtonPushed, true);
            app.CalcularButton.Position = [btn_x y_pos btn_w 30];
            app.CalcularButton.Text = 'Calcular';

            app.CerrarButton = uibutton(app.UIFigure, 'push');
            app.CerrarButton.ButtonPushedFcn = createCallbackFcn(app, @CerrarButtonPushed, true);
            app.CerrarButton.Position = [btn_x y_pos-dy btn_w 30];
            app.CerrarButton.Text = 'Cerrar';

            % ==========================================
            % GRÁFICA (Abarca el tercio inferior completo)
            % ==========================================
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Probabilidad de bloqueo (Erlang-B)')
            xlabel(app.UIAxes, 'Número de canales')
            ylabel(app.UIAxes, 'Probabilidad de bloqueo')
            app.UIAxes.Position = [30 30 800 200]; 
            app.UIAxes.Toolbar.Visible = 'off'; 
            grid(app.UIAxes, 'on');

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)
        function app = Tema3
            createComponents(app)
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end
        function delete(app)
            delete(app.UIFigure)
        end
    end
end

function Pb = erlang_b(A, N)
    if N == 0
        Pb = 1;
        return;
    end
    Pb = 1;
    for i = 1:N
        Pb = (A * Pb) / (i + A * Pb);
    end
end