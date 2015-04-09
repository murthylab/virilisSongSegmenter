function [plot_legends] = plot_distributions(Collect_file, file_names)

%%Plot multiple overlaping distributions.

plot_legends = cell(1,length(file_names));
%colors
cc=lines(length(file_names));
figure;
grid on;

for i = 1:length(file_names)
    [f, xi] = ksdensity(Collect_file.ipis{i});

    parsed_filename = textscan(file_names{i},'%s','Delimiter','_');
    ch = strcat(parsed_filename{1}(2));
    ch2 = Collect_file.kmodes(i);
    plot_legends(i) = strcat(ch, ' modes=', num2str(ch2));

hold on

plot(xi,f,'color',cc(i,:));

end
legend(plot_legends);








