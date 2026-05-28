FROM docker.elastic.co/elasticsearch/elasticsearch:8.19.15

COPY elasticsearch/config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

RUN elasticsearch-plugin install analysis-kuromoji
RUN elasticsearch-plugin install analysis-icu
RUN elasticsearch-plugin install analysis-smartcn
RUN elasticsearch-plugin install analysis-stempel
