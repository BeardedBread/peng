function peng()
clc;close all;
scrsz = get(0,'ScreenSize');
keypress_t = timer('ExecutionMode','fixedSpacing','Period',0.02,'TimerFcn',@control_window);
pressed_button = {};
ball_velocity = [1 1];
console_size = min(scrsz(3:4))./[2,10];
master = figure('ToolBar','none',...
    'Name','Pong Console','NumberTitle','off','MenuBar','none',...
    'Resize','off','Visible','off','Color',[170 255 211]/255,...
    'Position',[scrsz(3)/2-console_size(1)/2,15 console_size],...
    'KeyPressFcn',@key_press_check,'KeyReleaseFcn',@key_release_check,...
    'DeleteFcn',@exit_event);
%paddle_size = min(scrsz(3:4))./[10 4];
paddle_size = [50,200];
game_colour = [0 0 0]/255;
p2_fig = figure('ToolBar','none',...
    'Name','pong','NumberTitle','off','MenuBar','none',...
    'Resize','off','Visible','on','Color',game_colour,...
    'Position',[-paddle_size(1)*1.5,scrsz(4)/2 paddle_size]);
p2 = undecorateFig(p2_fig);
p1_fig = figure('ToolBar','none',...
    'Name','pong','NumberTitle','off','MenuBar','none',...
    'Resize','off','Visible','on','Color',game_colour,...
    'Position',[scrsz(3)-paddle_size(1),scrsz(4)/2 paddle_size]);
p1 = undecorateFig(p1_fig);
def_ball_pos = [scrsz(3)/2,scrsz(4)/2];
ball_fig = figure('ToolBar','none',...
    'Name','pong','NumberTitle','off','MenuBar','none',...
    'Resize','off','Visible','on','Color',game_colour,...
    'Position',[def_ball_pos min(scrsz(3:4)/15),min(scrsz(3:4)/15)]);
ball = undecorateFig(ball_fig);
P1_score = 0;
P2_score = 0;
P1_score_text = uicontrol('Style','text','Units','normalized',...
    'Position',[0.2 0.5,0.2,0.2],'Parent',master,'String',num2str(P1_score));
P2_score_text = uicontrol('Style','text','Units','normalized',...
    'Position',[0.7 0.5,0.2,0.2],'Parent',master,'String',num2str(P2_score));

set(master,'Visible','on');
%set(p1,'Visible','on');
%set(p2,'Visible','on');
%set(ball,'Visible','on');
figure(master);

start(keypress_t);

    function key_press_check(~,evtData)
        pressed_button = [pressed_button evtData.Key];
        pressed_button = unique(pressed_button);
    end
    function key_release_check(~,evtData)
        b = find(strcmp(pressed_button,evtData.Key)==1);
        %disp(b)
        pressed_button = [pressed_button(1:b-1) pressed_button(b+1:end)];
    end
    function control_window(~,~)
        if ~isempty(pressed_button)
            P1_up = (any(strcmp(pressed_button , 'uparrow')));
            P1_down = (any(strcmp(pressed_button , 'downarrow')));
            P1_y_move =  P1_down - P1_up;
            win_move = bound_window(0,P1_y_move,p1);
            if ~win_collide(win_move,ball)
                %set(p1,'Position',win_move);
                p1.setLocation(win_move(1), win_move(2));
            end
            
            P2_up = (any(strcmp(pressed_button , 'w')));
            P2_down = (any(strcmp(pressed_button , 's')));
            P2_y_move =  P2_down - P2_up;
            win_move = bound_window(0,P2_y_move,p2);
            if ~win_collide(win_move,ball)
                %set(p2,'Position',win_move);
                p2.setLocation(win_move(1), win_move(2));
            end
        end
        
        win_move = bound_window(ball_velocity(1),ball_velocity(2),ball);
        if win_collide(win_move,p1)
            approach_rebound(p1);
        elseif win_collide(win_move,p2)
            approach_rebound(p2);
        else
            %set(ball,'Position',win_move);
            ball.setLocation(win_move(1), win_move(2));
        end
        bounce_on_border();
        check_ball();
    end
    function approach_rebound(win)
        unit_move = ball_velocity(1:2)./sqrt(sum(ball_velocity(1:2).^2));
        %win_move = get(ball,'position');
        win_move = get_win_dimensions(ball);
        while ~win_collide(win_move + [unit_move 0 0],win)
            win_move = win_move + [unit_move 0 0];
        end
        if win_collide(win_move+[1 0 0 0],win) || win_collide(win_move+[-1 0 0 0],win)
            ball_velocity(1) = -ball_velocity(1);
        elseif win_collide(win_move+[0 1 0 0],win) || win_collide(win_move+[0 -1 0 0],win)
            ball_velocity(2) = -ball_velocity(2);
        end
    end
    function [newwin_pos] = bound_window(x_move,y_move,win_handle)
        %newwin_pos = get(win_handle,'Position');
        newwin_pos = get_win_dimensions(win_handle);
        if (any(abs([x_move y_move])))
            speed = 15;
            newwin_pos = newwin_pos + speed*[x_move y_move 0 0];
%             newwin_pos(1) = max(newwin_pos(1),scrsz(1));
%             newwin_pos(1) = min(newwin_pos(1),scrsz(3)-newwin_pos(3));
            newwin_pos(2) = max(newwin_pos(2),scrsz(2));
            newwin_pos(2) = min(newwin_pos(2),scrsz(4)-newwin_pos(4));
        end
    end
    function [collision] = win_collide(newpos,win_col)
        collision = 0;
        %win_col_pos = get(win_col,'Position');
        win_col_pos = get_win_dimensions(win_col);
        if ((newpos(1)>win_col_pos(1) && newpos(1)<win_col_pos(1)+win_col_pos(3)) ||...
                (newpos(1)+newpos(3)>win_col_pos(1) && newpos(1)+newpos(3)<win_col_pos(1)+win_col_pos(3)))...
                &&((newpos(2)>win_col_pos(2) && newpos(2)<win_col_pos(2)+win_col_pos(4))||...
                (newpos(2)+newpos(4)>win_col_pos(2) && newpos(2)+newpos(4)<win_col_pos(2)+win_col_pos(4)))
            collision = 1;
        end
    end
    function bounce_on_border()
        %win_pos = get(ball,'Position');
        win_pos = get_win_dimensions(ball);
        if( any(win_pos(2) == [scrsz(2) scrsz(4)-win_pos(4)]))
            ball_velocity(2) = -ball_velocity(2);
        elseif ( any(win_pos(1) == [scrsz(1) scrsz(3)-win_pos(3)]))
            ball_velocity(1) = -ball_velocity(1);
        end
    end
    function check_ball()
        goal = 0;
        %ball_pos = get(ball,'Position');
        ball_pos = get_win_dimensions(ball);
        if ball_pos(1)+ball_pos(3)<scrsz(1)
            P2_score = P2_score+1;
            goal = 1;
            %set(ball,'Position',[def_ball_pos.*[1.5 1] ball_pos(3:4)]);
            ball.setLocation(def_ball_pos(1)*1.5,def_ball_pos(2));
        elseif ball_pos(1)>scrsz(1)+scrsz(3)
            P1_score = P1_score+1;
            %set(ball,'Position',[def_ball_pos.*[0.5 1] ball_pos(3:4)]);
            ball.setLocation(def_ball_pos(1)*0.5,def_ball_pos(2));
            goal = 1;
        end
        if goal
            update_score()
        end
    end
    function update_score()
        set(P1_score_text,'String',num2str(P1_score));
        set(P2_score_text,'String',num2str(P2_score));
    end
    function exit_event(~,~)
        delete_timers();
        close_all_windows();
    end
    function delete_timers
        alltimer = timerfindall();
        stop(alltimer);
        delete(alltimer);
    end
    function close_all_windows
        %close(p1);
        %close(p2);
        %close(ball);
        close(p1_fig);
        close(p2_fig);
        close(ball_fig);
        dispose(p1);
        dispose(p2);
        dispose(ball);
    end
    function dims = get_win_dimensions(win)
        r = win.getBounds();
        dims = [win.getX(),win.getY(),r.width,r.height];
    end
end