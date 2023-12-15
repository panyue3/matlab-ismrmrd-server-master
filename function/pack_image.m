        function image = pack_image(data, info)

            % Create MRD Image object, set image data and (matrix_size, channels, and data_type) in header
            image = ismrmrd.Image(data);

            % Copy original image header, but keep the new data_type
            data_type = image.head.data_type;
            image.head = info.head;
            image.head.data_type = data_type;
            image.head.matrix_size = size(data, [1 2 3]);

            % Add to ImageProcessingHistory
            meta = ismrmrd.Meta.deserialize(info.attribute_string);
            meta = ismrmrd.Meta.appendValue(meta, 'ImageProcessingHistory', 'PROMPT');
            meta = ismrmrd.Meta.appendValue(meta, 'WindowCenter', 40);
            meta = ismrmrd.Meta.appendValue(meta, 'WindowWidth', 80);
            image = image.set_attribute_string(ismrmrd.Meta.serialize(meta));

        end % end of pack_image